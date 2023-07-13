#!/usr/bin/python3
# Copyright 2023 Ronald S. Burkey <info@sandroid.org>
#
# This file is part of yaAGC.
#
# yaAGC is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# yaAGC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with yaAGC; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Filename:     yaASMflowchart.py
# Purpose:      The idea behind this program is the observation that certain
#               aspects of the program comments of LVDC flight programs AS-512
#               and AS-513, particularly the markings in column 71, *may* be 
#               instructions for automated generation of flowcharts.  This 
#               program attempts to construct such flowcharts by extracting the
#               markings in question from the source code and generating a
#               program from them in the DOT language for subsequent processing
#               by graphviz software.  Requires source code in .lvdc format
#               (vs .lvdc8 format).
# Reference:    http://www.ibibio.org/apollo
# Mods:         2023-07-07 RSB  Began.
#               2023-07-10 RSB  "Working", at least for AS-512 FR.

'''
Input is on stdin.  Any given source-code input file may actually represent
several flowcharts, and graphviz can only render a single flowchart from any
given DOT-language file.  Therefore, rather than output a DOT file on stdout,
one or more DOT files are generated directly.  These have names derived from
the names as given in the program comments, specifically in the comments which
are "J" annotations.  For example, a flowchart beginning with the source-code
line

*      ABSOLUTE/COMMAND FREEZE UTILITY (FR)                          *J

might have the filename ABSOLUTE-COMMAND_FREEZE_UTILITY.dot.

Anyway, my recommendation is to use with the command-line switch --sdl, as in

    yaASMflowchart.py --sdl <SOURCE.lvdc

and to convert the resulting DOT file (supposing there were only one of them)
to postscript format with

    dot -Tps -l sdl.ps <yaASMflowchart-01.dot >test.ps

The temp.ps file is the rendering of the flowchart, and it can be viewed with
a postcript viewer or else somehow converted a some more-common format like
pdf, svg, or png.  For example, the postscript file could be converted to other 
formats with GIMP or ImageMagick.  The former is interactive and its usage is
obvious (for GIMP-savvy users), though be certain to select the strongest 
antialiasing options you're presented with.  With ImageMagick, you could use a 
command like

    convert -density 100 test.ps -background white -flatten test.png
    
where the DPI is adjustable by changing the number after the -density switch.
On Linux at least, there are other common converter programs such as ps2pdf, but
with the ones I've tried, care has to be taken with the paper sizes chosen, to 
avoid the drawing being clipped.  Whereas GIMP and ImageMagick don't have that 
problem and don't require selection of a paper size at all.

Although ... in googling to check the details ImageMagick commands I gave above,
it appears to me that ImageMagick may have undergone an asinine incompatible
rework of its entire command-line interface, so I cannot guarantee that any
ImageMagick commands I list will work on your computer, either now or into the
future.  Perhaps you may have to use "magick convert" in place of "convert", 
or may have to use "magick" directly but with different command-line options.
Alas, I just don't know, since this "improved" user interface seemingly isn't
present in the version of ImageMagick on my computer.  I don't mind a new user
interface, of course, but deprecating the old one that has been in use for so
long is what seems idiotic.  Sorry for the editorializing.  But not really.

These particular instructions use a non-default configuration of graphviz, in
that several of the natively-included node shapes just don't look good in the
flowcharts, and are instead replaced by custom node shapes (downloaded from the
web, not designed by me!) that look much better.  The drawback is that these
custom shapes are postscript only, and that's why we output a postscript file.
If one were willing to live with the native graphviz shapes, then formats like
pdf, png, jpg, svg, etc., could all be output directly from dot, without any
extra conversion step.  For example, the commands for directly producing svg 
(using native graphviz shapes) would be:

    yaASMflowchart.py <SOURCE.lvdc
    dot -Tsvg <yaASMflowchart-01.dot >test.svg

and the other formats could be produced using obvious variants of the latter.

Here's my interpretation of what's in column 71:

    J Start of a flowchart.
    H End of a flowchart

    S Entry point.
    X Exit point (including RETURN).
    
    Q Decision box.
    Y "Yes" arrow from decision box.
    N "No" arrow from decision box.
    G Unconditional goto.
    
    P Process (subroutine all or macro expansion)
    
See also:  https://sketchviz.com/flowcharts-in-graphviz
'''

import sys
import re
import textwrap
import copy

# Unfortunately, graphviz does not offer a rectangle with semicircular 
# right/left ends as a node shape, and that's what's needed for proper 
# ENTRY and EXIT nodes in a software flowchart.  The closest it offers
# natively is a rounded rectangle, and that's what I use by default, but
# it just isn't quite right.  There's an external library of "sdl" shapes,
# contrib/sdl.ps, that can be downloaded from the graphviz source tree,
# and it includes a shape that's exactly right.  Unfortunately, it only
# works if you produce the flowcharts in postscript format, so I don't
# enable it by default.  To used it, add the --sdl CLI switch. 
if "--sdl" in sys.argv[1:]:
    startShape = "shape=sdl_start peripheries=0"
    callShape = "shape=sdl_call peripheries=0"
    decisionShape = "shape=diamond height=1"
    ioShape = "shape=sdl_save peripheries=0"
    connectorShape = "shape=sdl_connector peripheries=0"
else:
    startShape = "style=rounded"
    callShape = ""
    decisionShape = "shape=diamond height=1"
    ioShape = "shape=parallelogram height=1"
    connectorShape = "shape=circle"
leftJustify = ("--left-justify" in sys.argv[1:])
if leftJustify:
    if "--inconsolata" in sys.argv[1:]:
        fixedFont = "inconsolata"
    else:
        fixedFont = "courier"

flowchart = []
lineNumber = 0
for line in sys.stdin.readlines():
    lineNumber += 1
    line = line.rstrip()
    
    match = re.search("^[A-Z][.A-Z0-9]*\\b", line)
    label = ""
    labelFrom = "Nowhere"
    if match != None:
        label = match.group()
        labelFrom = "Label"
    lhs = label
        
    if line[:1] in ["$", "#"] or line.startswith("       TITLE"):
        if label != "":
            flowchart.append({
                "col71" : "-", 
                "comment": "", 
                "label": label, 
                "labelFrom": labelFrom,
                "lhs": lhs,
                "opcode": "",
                "operand": "", 
                "lineNumber": lineNumber,
                "lineNumberCount": 0,
                "line": line,
                "heading": ""})
        continue
    if len(line) < 71:
        line = "%-71s" % line
    
    opcode = ""
    operand = ""
    col71 = line[70]
    line = line[:70].rstrip()
    if len(line) < 15:
        continue
    heading = ""
    if line[0] == "*":
        # Full-line comment.
        dummy = line[1:]
        if len(dummy) == 0:
            continue
        while len(dummy) > 0 and dummy[0] != " ":
            heading += dummy[0]
            dummy = dummy[1:]
        if col71 == "S" and heading == "":
            heading = dummy.strip()
        comment = dummy[1:].lstrip()
    else:
        # We have to find the comment field.  To do that, we first have to 
        # find the end of the operand field, if any.
        comment = ""
        opcode = line[7:15].strip()
        col = 15
        while col < len(line) and line[col] != " ":
            col += 1
        operand = line[15:col].strip()
        if col < len(line):
            comment = line[col:].lstrip()
    if comment.startswith("(") and ")" in comment:
        end = comment.index(")")
        heading = comment[:end+1]
        comment = comment[end+1:] 
    elif label != "" and col71 not in ["P"]:
        heading = label
    elif opcode.startswith("HOP") and operand != "":
        heading = operand
    if heading == comment:
        comment = ""
    flowchart.append({
        "col71" : col71, 
        "comment": comment, 
        "label": label, 
        "labelFrom": labelFrom,
        "lhs": lhs,
        "opcode": opcode,
        "operand": operand, 
        "lineNumber": lineNumber,
        "lineNumberCount": 0,
        "line": line,
        "heading": heading})
    
if False:
    for entry in flowchart:
        print("")
        for key in entry:
            print(key, ":", entry[key])
    sys.exit(0)
    
inJ = False
title = ""
nodes = {}
arrows = []
destinations = {}
precedingNode = ""

tbdMessages = []
def TBD():
    if col71 not in tbdMessages:
        tbdMessages.append(col71)
        print("Directive %s not yet fully implemented" % col71)

# Format text for inclusion in a box.
def formatText(text, heading, lineLength=24):
    if heading != "":
        heading = heading + "\n"
    # This performs word-wrapping.
    lines = textwrap.wrap(text, lineLength, break_long_words=False)
    if leftJustify and len(lines) > 1:
        for i in range(len(lines)):
            lines[i] = lines[i].ljust(lineLength, " ")
    text = heading + "\n".join(lines)
    return text

def printFlowchart(title):
    filename = title.replace("/", "-").replace(" ", "_") + ".dot"
    file = open(filename, "w")
    print("digraph {", file=file)
    print("\tlabel = \"%s\n \"" % title, file=file)
    print("\tlabelloc = t", file=file)
    print("\tfontsize = 20", file=file)
    print("\tfontcolor = blue", file=file)
    #print("\tsplines=false", file=file)
    if leftJustify:
        print("\tnode [shape=rect fontname=\"%s\" fontsize=12]" \
              % fixedFont, file=file)
    else:
        print("\tnode [shape=rect]", file=file)
    
    print("", file=file)
    lastNode = ""
    for nodeName in nodes:
        node = nodes[nodeName]
        nodeType = node["col71"]
        nodeIdentifier = "n%08d_%03d" % \
            (node["lineNumber"], node["lineNumberCount"])
        if nodeType in ["S", "X", "D"]:
            text = formatText(node["text"], node["heading"])
            attributes = "%s label=\"%s\"" % (startShape, text)
        elif nodeType == "G":
            text = formatText(node["text"], node["heading"])
            attributes = "%s label=\"%s\"" % (startShape, text)
        elif nodeType == "P":
            text = formatText(node["text"], node["heading"])
            attributes = "%s label=\"%s\"" % (callShape, text)
        elif nodeType in ["B", "M", "D", "L"]:
            text = formatText(node["text"], node["heading"])
            attributes = "label=\"%s\"" % text
        elif nodeType == "Q":
            text = formatText(node["text"], node["heading"], 12)
            # I don't like using an absolute height here, but I haven't
            # found any other way to keep the diamond from being very wide
            # and skinny.
            attributes = "%s label=\"%s\"" % (decisionShape, text)
        elif nodeType == "I":
            text = formatText(node["text"], node["heading"])
            attributes = "%s label=\"%s\"" % (ioShape, text)
        elif nodeType in ["-", "+"]:
            if nodeType == "-" and nodeName not in destinations:
                continue
            text = node["label"]
            attributes = "%s label=\"%s\"" % (startShape, text)
        print("\t%s [%s]" % (nodeIdentifier, attributes), file=file)
        if False:
            # The following is just a temporary measure to keep the nodes
            # stacked vertically until I begin to add actual arrows.
            if lastNode != "":
                print("\t%s -> %s [style=invis, weight=10]" \
                      % (lastNode, nodeIdentifier), file=file)
        lastNode = nodeIdentifier
    
    print("", file=file)
    for arrow in arrows:
        if arrow[0] not in nodes:
            print("Could not find arrow source", arrow[0], file=sys.stderr)
            continue
        node0 = nodes[arrow[0]]
        if arrow[1] not in nodes:
            print("Could not find arrow target", arrow[1], file=sys.stderr)
            continue
        node1 = nodes[arrow[1]]
        caption = arrow[2]
        nodeIdentifier0 = "n%08d_%03d" % \
            (node0["lineNumber"], node0["lineNumberCount"])
        if node0["col71"] not in ["S", "X", "D", "G", "-", "Q"]:
            nodeIdentifier0 = nodeIdentifier0 + ":s"
        nodeIdentifier1 = "n%08d_%03d" % \
            (node1["lineNumber"], node1["lineNumberCount"])
        if node1["col71"] not in ["S", "X", "D", "G", "-"]:
            nodeIdentifier1 = nodeIdentifier1 + ":n"
        if arrow[2] != "":
            print("\t%s -> %s [label=\"%s\"]" % \
                  (nodeIdentifier0, nodeIdentifier1, caption), file=file)
        else:
            print("\t%s -> %s" % (nodeIdentifier0, nodeIdentifier1), \
                  file=file)
    
    print("}", file=file)
    file.close()

# In general, boxes are added to the flowchart principally because of
# markings in column 71.  However, there are cases when the boxes are added
# even though they have no markings, but have a symbolic label in the 
# label field.  These are needed because not all potential entry points and
# targets of control transfers are indicated in column 71.  With the 
# processing so far, however, all such labels have added nodes and edges,
# and most of them aren't needed.  So this is an optimization step which
# removes those nodes that aren't needed, and consolidates their edges.
def removeSuperfluous():
    return

# Up to this point, nodes may have multiple arrows targeting them.  In
# flowchart theory, however, this should only be possible for "connector"
# nodes (none of which have been added so far), so the following function
# tries to insert connector nodes whenever a non-connector node has multiple
# incoming arrows.
def addConnectors():
    return

# This subroutine is entered whenever a flowchart (started by J and ending
# with H, or another J, or the end of file) is being closed out and printed.
# Additionally, several types of beautifications may be performed before
# printing.
def cleanup(title):
    global inJ, arrows
    if inJ:
        removeSuperfluous()
        addConnectors()
        printFlowchart(title)
        inJ = False

# Add an arrow from node #1 to node #2.
queryStatus = {}
def addArrow(node1, node2, caption="", yn=""):
    global arrows, nodes, precedingNode, queryStatus
    if caption == ""  and queryStatus != {} \
            and (queryStatus["yes"] ^ queryStatus["no"]):
        if queryStatus["yes"]:
            caption = "NO"
            queryStatus = {}
        else:
            caption = "YES"
            queryStatus = {}
    if node1 != "":
        if node2 not in destinations:
            destinations[node2] = 1
        else:
            destinations[node2] += 1
        arrows.append((node1, node2, caption))
        if nodes[node1] == "Q":
            if yn == "Y":
                nodes[node1]["yesUsed"] = True
            elif yn == "N":
                nodes[node1]["noUsed"] = True
            if nodes[node1]["yesUsed"] and nodes[node1]["noUsed"]:
                precedingNode = ""

lastLineNumber = 0
lineNumberCount = 0
lastUnmarked = {}
for entry in flowchart:
    col71 = entry["col71"]
    comment = entry["comment"]
    comment.replace('"', "'")
    opcode = entry["opcode"]
    operand = entry["operand"]
    label = entry["label"]
    labelFrom = entry["labelFrom"]
    lhs = entry["lhs"]
    lineNumber = entry["lineNumber"]
    if lineNumber == lastLineNumber:
        lineNumberCount += 1
    else:
        lineNumberCount = 0
        lastLineNumber = lineNumber
    entry["lineNumberCount"] = lineNumberCount
    heading = entry["heading"]
    if inJ and lhs != "" and precedingNode == "" and heading != lhs:
        #print("!", entry)
        nodes[lhs] = {
            "col71" : "+", 
            "comment": "", 
            "label": lhs, 
            "labelFrom": "Label",
            "lhs": lhs,
            "opcode": "",
            "operand": "", 
            "lineNumber": lineNumber,
            "lineNumberCount": lineNumberCount,
            "line": line,
            "heading": lhs}
        lineNumberCount += 1
        entry["lineNumberCount"] = lineNumberCount
        precedingNode = lhs
        lhs = ""
        label = ""
        entry["label"] = ""
        entry["lhs"] = ""
    if label == "":
        label = "node%d_%03d" % (lineNumber, lineNumberCount)
    if col71 == "J":
        cleanup(title) # Allow for missing H at end of preceding flowchart.
        inJ = True
        title = comment
        if title[-1] == "*":
            title = title[:-1].rstrip()
        nodes = {}
        arrows = []
        precedingNode = ""
    elif col71 == "H":
        cleanup(title)
    elif inJ:
        if col71 == " ":
            lastUnmarked = entry
        elif col71 == "$":
            pass # Ignore these
        elif col71 == "S":
            startLabel = heading
            if startLabel == "":
                print("Unnamed entry point:", entry, file=sys.stderr)
            elif startLabel in flowchart:
                print("Start point (%s) already defined" % startLabel, \
                      file=sys.stderr)
            else:
                nodes[startLabel] = entry
                entry["text"] = ""
                precedingNode = startLabel
        elif col71 in ["X"] or \
                (col71 in ["C","G"] and \
                 (opcode.startswith("HOP") or opcode.startswith("TRA"))):
            if col71 in ["C","G"] and comment != "RETURN":
                exitLabel = operand
            else:
                exitLabel = comment
            if exitLabel not in nodes:
                entry["heading"] = exitLabel
                entry["text"] = ""
                nodes[exitLabel] = entry
            addArrow(precedingNode, exitLabel)
            precedingNode = ""
        elif col71 in ["B", "M", "D", "P", "I", "L"]:
            entry["text"] = comment
            nodes[label] = entry
            addArrow(precedingNode, label)
            precedingNode = label
        elif col71 == "Q":
            entry["text"] = comment
            nodes[label] = entry
            addArrow(precedingNode, label)
            entry["noUsed"] = False
            entry["yesUsed"] = False
            precedingNode = label
            queryStatus = { "yes": False, "no": False }
        elif col71 == "G":
            TBD()
        elif col71 in ["Y", "N"]:
            if precedingNode not in nodes:
                continue
            if queryStatus == {}:
                # For some reason, the Query wasn't marked as such.
                # We're going to convert the present Y or N line into a
                # Q line and insert a decision box for it.
                entry["text"] = comment
                entry["col71"] = "Q"
                nodes[label] = entry
                addArrow(precedingNode, label)
                entry["noUsed"] = False
                entry["yesUsed"] = False
                precedingNode = label
                queryStatus = { "yes": False, "no": False }
                # Note that the col71 variable is unchanged at Y or N.
            query = nodes[precedingNode]
            if not queryStatus["yes"] and not queryStatus["no"]:
                # The TRA/HOP may seem out of place here.  But I've found a
                # number of instances with a Y or an N not preceded by a 
                # Q and using a TRA.
                startTRAHOP = opcode.startswith("TRA") or \
                            opcode.startswith("HOP")
                if opcode.startswith("TMI") or opcode.startswith("TNZ") \
                        or startTRAHOP:
                    if col71 == "Y":
                        queryStatus["yes"] = True
                        addArrow(precedingNode, operand, "YES")
                    else:
                        queryStatus["no"] = True
                        addArrow(precedingNode, operand, "NO")
                    if startTRAHOP:
                        precedingNode = ""
                else:
                    print("Yes/No at line %d is not TMI/TNZ: %s" \
                          % (lineNumber, opcode))
            elif queryStatus["yes"] and not queryStatus["no"]:
                if col71 == "N":
                    addArrow(precedingNode, operand, "NO")
                    precedingNode = ""
                    queryStatus = {}
                else:
                    print("Duplicated N at line %d for Query" \
                          % lineNumber)
            elif queryStatus["no"] and not queryStatus["yes"]:
                if col71 == "Y":
                    addArrow(precedingNode, operand, "YES")
                    precedingNode = ""
                    queryStatus = {}
                else:
                    print("Duplicated Y at line %d for Query" \
                          % lineNumber)
            else:
                # This can't happen, I think.
                precedingNode = ""
                queryStatus = {}
        elif col71 == "E":
            TBD()
        elif col71 == "*":
            TBD()
        elif col71 == "-":
            # Note that col71 of "-" or "+" is something I use for internal
            # processing of lines with a symbolic label in the label field
            # and " " in column 71.  They're not markings that actually 
            # appear in assembly listings.
            nodes[label] = entry
            if precedingNode == "":
                entry["col71"] = "+"
                entry["text"] = label
            else:
                addArrow(precedingNode, label)
            precedingNode = label
        else:
            print("Unknown directive %s in line \"%s\"" % \
                  (col71, entry["line"]))

cleanup(title) # Allow for missing H at end of file.
