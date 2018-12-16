#!/usr/bin/python2
# I, the author, Ron Burkey, declare this to be in the Public Domain.

# Creates an HTML table with one column, namely a series of hyperlinks to successive 
# pages of a document on archive.org.

import sys

if len(sys.argv) < 3:
	print >> sys.stderr, "Usage:"
	print >> sys.stderr, "\tmakeArchiveOrgLinkColumn.py BASEURL NUMPAGES >OUTPUT.html"
	print >> sys.stderr, "BASEURL is something like AgcApertureCardsBatch7, and not a"
	print >> sys.stderr, "full URL."
	sys.exit(1)

baseUrl = sys.argv[1]
numPages = int(sys.argv[2])

print "<table>"
for i in range(0, numPages):
	print "<tr><td><a href=\"https://archive.org/stream/" + baseUrl + "#page/n" + str(i) + "/mode/1up\">" + str(i+1) + "</td></tr>"
print "</table>"
