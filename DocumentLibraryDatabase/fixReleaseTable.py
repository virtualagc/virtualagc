#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     fixReleaseTable.py
# Purpose:	     Helps to convert a table maintained in a Google Sheets
#               or LibreOffice Calc spreadsheet into a form suitable for 
#               pulling into the Virtual AGC website's HTML.  Right now, the
#               only example is the table of AGC software releases, but it
#               should be fine for any spreadsheet.  The point of the 
#               processing is to remove all styling and just retain vanilla
#               content. 
# Mod history:  2021-09-27 RSB  Began
#
# The best working procedure is this:
#
#   For a Google Sheets spreadsheet, cut-and-paste into LibreOffice Calc.
#
#   For a LibreOffice Calc spreadsheet, "export" as XHTML.
# 
# Note that (at present) this produces a <body> section that's all in one long 
# line of text, making pattern recognition and search-and-replace very easy.
# Simply "downloading" from Google Sheets as HTML produces a more-complicated
# object (without <body> tag) that wouldn't be processed properly with the 
# current code.
#
#   Process the exported HTML file:
#	./fixReleaseTable.py <Exported.html >fixedExported.html
#
# This outputs just the inside of the <body> section, and not a full HTML 
# file.  So all it should contain is the <table> corresponding to the 
# original spreadsheet.

import sys
import re

outsideBody = True
firstRow = True
lines = sys.stdin.readlines()
for line in lines:
    line = re.sub("<colgroup>.*</colgroup>", "", line)
    line = re.sub(" *(class|style)=\"[^\"]*\"", "", line)
    line = re.sub("https?://www[.]ibiblio[.]org/apollo/+", "", line)
    line = re.sub("<tr\\s*>(\\s*<td\\s*>\\s*</td>)*\\s*</tr>", "", line)
    #line = re.sub("<tr*>(<td>\\s*</td>)*</tr>", "", line)
    if outsideBody and "<body" not in line:
        continue
    fields = line.split("<");
    for field in fields:
        chunk = "<" + field
        if outsideBody:
            if "<body" in chunk:
                outsideBody = False
                chunk = re.sub("<body[^>]*>", "", chunk)
                if chunk != "":
                    print(chunk, end="")
            continue
        if "</body>" in chunk:
            outsideBody = True
            break
        if "<table" in chunk:
            chunk = re.sub("<table[^>]*>", "<table align=\"center\" border=\"1\" cellspacing=\"2\" cellpadding=\"2\">", chunk)
        if "</tr>" in chunk:
            firstRow = False
        if firstRow:
            if "<td" in chunk:
                chunk = "<th" + chunk[3:]
            elif "</td>" in chunk:
                chunk = "</th>" + chunk[5:]
        if "<p>" in chunk:
            chunk = chunk[3:]
            if chunk != "":
                print(chunk, end="")
                continue
        if "</p>" in chunk:
            chunk = "<br>" + chunk[4:]
        chunk = chunk
        if chunk != "":
            print(chunk, end="")
