#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPage.py
# Purpose:	     Builds a Virtual AGC Project "document library" web page from
#               a database of documents stored on the site. 
# Mod history:  2021-09-08 RSB    Began
#
# Usage:
#	./buildLibraryPage.py <DocumentLibraryDatabase.tsv >../linksAuto.html
#
# Up to this point (2021-09-08), the document-library page (links.html) has
# been a manually-maintained HTML file. That worked fine 18 years ago when
# there was little on the page other than the 100 or so documents that had
# been on the now-defunct HRST website.  Nowadays, when there's more like
# 3000 documents, and there are days when 100+ are added on that day alone,
# it's much tougher to manage.  Some points of difficulty are that documents
# can get categorized oddly, wherein they're stuck in unusual sections of the
# page and are hard to find.  They're also hard to move, since doing so
# (in Mozilla Composer, the only satisfactory WYSIWYG HTML editor I know), 
# because Composer keeps changing the links to ones on the local drive, which
# you have to remember to fix.  And then there's the NEW icon I stick next to
# newly-added files; and it doesn't help!  So I want a much more flexible way
# to be able to restructure the document-library page and to have better ways
# of finding what I want to find on it.
#
# The whole thing depends on a "database", which I'm maintaining as a Google
# Sheet on the cloud, called "Virtual AGC Document Library Database", and 
# which is supposed to be exported as a TSV file from time to time, and 
# kept in DocumentLibraryDatabase/DocumentLibraryDatabase.tsv, along with
# this script, DocumentLibraryDatabase/buildLibraryPage.py.  The idea is that
# this script is run, from time to time, to regenerate the document-library
# page.
#
# I may also eventually want to use the DocumentLibraryDatabase.tsv file
# to create a JSON file which can be embedded in a search page.  But that
# has nothing to do with this script, and I'm undecided anyway since I'm not
# sure that a search page would have any value added over the Google searchbar
# I now embed on every Virtual AGC web-page anyway.
#
# The TSV database is structured as follows, with one line per file (except 
# the top line, which is a header):
#
#   Field 1     DateAdded.  This is an optional field of the form MM/DD/YYYY,
#               which indicates the date when the document file was added to
#               the library.  This used for automatically determining which
#               document files are newly added and therefore need to be
#               displayed to the user differently.  If the field is empty,
#               then the document file's filesystem timestamp is used instead.
#               Actually, we always use the later of the DateAdded and file
#               timestamps when collating, since obviously the file couldn't
#               have been added before it existed.
#
#   Field 2     DocumentDate.  This is supposed to be the date the document
#               is explicitly dated.  The format is MM/DD/YYYY, but any
#               unknown field can be filled with '?'.  So for example, if only
#               the month and day were known, then MM/??/YYYY.  If the date
#           `   were completely unknown, it would be ??/??/????.
#
#   Field 3     DocumentID.  This is the document number originally assigned
#               back during Apollo, such as "R-567" or "LUMINARY Memo #125".
#               If there's more than one document number assigned to the same
#               document, such as "MSC12345" and "71-FM-8765", they are
#               separated by commas.  Usually the formatting of document 
#               numbers is peculiar to each organization doing it, so it is
#               helpful to designate the organization recognizing/assigning the
#               document number.  This can be done by suffixing the 
#               organization name to the document number, delimited by '/'.
#               For example, "R-567/IL, MSC5678/MSC" would mean that the
#               document had MIT Instrumentation Lab number R-567, but 
#               Manned Spacecraft Center number MSC5678. Here are some 
#               organization suffixes I've been using so far:
#                   IL          Instrumentation lab or Charles Stark Draper Lab
#                   AC          AC Electronics or Delco Electronics
#                   MSC         Manned Spacecraft Center
#                   GAEC        Grumman
#                   NAA         North American
#                   TRW         TRW
#                   IBM         IBM Federal Systems Division
#                   NASA        NASA other than MSC.
#                   Raytheon    Raytheon
#               Note that the document numbers themselves cannot contain
#               '/' or ',', so if they do have those characters, remove or 
#               substitute them somehow.
#
#   Field 4     Revision.  Empty for initial version or unknown.  I also 
#               sometimes put "Draft" or "Preliminary" as the revision level.
#
#   Field 5     DocumentPortion.  If the file contains the entire document, 
#               blank. But the file may be one of a multivolume set, or just 
#               some range of sections, or just a table, or some other portion 
#               of the entire document.  In that case, this field is a very 
#               concise description of the portion.
#               
#   Field 6     Author name.  If unknown, or an organization rather than a
#               person, may be left blanks.  If there are multiple authors,
#               they can be comma-delimited.  If the authors are a part of 
#               some known organization, that affiliation can be appended with
#               a "/".  For example "Hugh Blair-Smith/IL, Jay Sampson/AC".
#               Note that name suffixes like "Jr." can be used but must not 
#               have commas included.  Thus, "Abe Barlow Jr." rather than
#               "Abe Barlow, Jr.".
#
#   Field 7     Target.  The document may be targeted for things like specific
#                   Mission (AS-204, Apollo 7, etc)
#                   Spacecraft (LM-3, SC-012)
#                   Program names (COLOSSUS, LUMINARY, LUMINARY 1E)
#                   Program revision (COMARNCHE 55, LUMINARY 131 rev 1)
#               or some comma-delimited list.
#
#   Field 8     Keywords.  I have in mind examples like "Testing", 
#               "Simulation", "Software", "Hardware", "G&N", "Pad Load", 
#               "Erasable Memory Program", and so on, or any comma-delimited
#               list of keywords.  I doubt that the Target field and the 
#               Keywords field will be treated very differently, though, 
#               as they're both intended to provide ways to categorize the
#               files and thus segregate them appropriately in the document
#               library page.
#
#   Field 9     Absolute URL to the file, for making hyperlinks.  If there's 
#               more than one available file, their URLs should be 
#               comma-delimited, and they should be arranged in order of 
#               most-preferable to least-preferable.  That's a subjective 
#               judgement, of course, but basically it comes down to 2 cases: 
#               If one file is of reasonably-comparable visual quality but is 
#               much smaller than the other, then it is preferable.  
#               Conversely, if the files are reasonably comparable in size but 
#               one is much-more-legible, then it is the preferable one.
#
#   Field 10    Title of the document or partial document; or failing that,
#               a reasonable description.
#
#   Field 11    ContributingArchive.  This is, of course, whoever we got the
#               document from, whether or not they provided much cooperation
#               in doing so.  For example, some common examples are Don Eyles,
#               MIT Museum, NARA-SW, UHCL, NTRS, etc.  The field can be
#               left empty --- certainly on a temporary basis --- but it would
#               be nice to know where some of this stuff came from.  
#               Unfortunately, in the old days I used to change the incoming
#               filenames (often, useless strings of random numbers) to 
#               meaningful description, and because of that I no longer can
#               trace them back to the source.  If there are multiple URLs 
#               in field 9, then there may be multiple archives here, 
#               comma-delimited, and in the same order as field 9.
#
#   Field 12    Scanner.  If some person freely scanned the documemt, or paid
#               to have it scanned, or transcribed it, then that person's 
#               name can be put here.  Or it can be left empty.  If there
#               are multiple URLs in field 9, then there may be multiple 
#               names here, comma-delimited, and in the same order as field 9.
#               Note that name suffixes like "Jr." can be used but must not 
#               have commas included.  Thus, "Abe Barlow Jr." rather than
#               "Abe Barlow, Jr.".
#
#   Field 13    Unlucky field 13 is the Disclaimer.  This is hardly ever
#               necessary, but some archives require as a part of their terms
#               of service, that you pay obeisance to them using some 
#               formalized phrases which which they supply you, such as
#               "We praise the almighty XXX Archive for graciously allowing 
#               us to pay them a fee to show you this document, even though
#               their entire contribution to creating this public-domain
#		     document (paid for with our tax dollars) was nil,
#               and all they did was leave it sitting in a box for 30 years
#               after some reasonably famous person donated it to them."
#               Theoretically there could be multiple disclaimers if a given
#               document had multiple digitizations from different sources, 
#               however, we just lump them all into one big string.  It's
#               used as-is in the website, so use HTML.
#
#   Field 14    A comment (in HTML) what will be added as-is to the document's
#               entry on the library page.  Fortunately, I've seldom done that
#               in the past, but it needs to be done sometimes.

import sys
import os
import time
from datetime import datetime, date

oldRemote = "http://www.ibiblio.org/apollo/"
remote = "https://www.ibiblio.org/apollo/"
local = "/home/rburkey/Desktop/sandroid.org/public_html/apollo/"
lenOldRemote = len(oldRemote)
lenRemote = len(remote)
lenLocal = len(local)

# Given a field from the database which is supposed to be a date (MM/DD/YYYY, 
# but possibly with unknown fields like ??, or things like M/D/YY), parses
# it into month, day, and year fields (strings) with the appropriate widths.
# The defaultYear parameter will be "19" for the original document dates,
# or "20" for the year added to the database.
def parseDate(dateString, defaultYear):
    illegal = True
    month = ""
    day = ""
    year = ""
    if dateString.strip() != "":
        dateFields = dateString.strip().split('/')
        if len(dateFields) == 3:
            month = dateFields[0].strip()
            day = dateFields[1].strip()
            year = dateFields[2].strip()
            if month[:1] == "?":
                month = ""
            if day[:1] == "?":
                day = ""
            if year[:1] == "?":
                year = ""
            if len(month) == 1:
                month = "0" + month
            if len(day) == 1:
                day = "0" + day
            if len(month) in [0,2] and len(day) in [0,2] and len(year) in [0,2,4]:
                if len(year) == 2:
                    year = defaultYear + year
                illegal = False
        if illegal:
            print("Illegal date field: " + dateString, file=sys.stderr)
    return (illegal, month, day, year)

# Parse a simple comma-delimited list appearing in a database field.
def simpleList(field):
    if field.strip() == "":
        return []
    array = field.split(",")
    for n in range(len(array)):
        array[n] = array[n].strip()
    return array

# Make a filesize human-friendly.  Simplified from stack overflow.
def friendlyFilesize(num):
    if num == "":
        return ""
    suffix = "B"
    for unit in ['','K','M','G']:
        if abs(num) < 1000.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1000.0
    return "%.1f%s%s" % (num, 'T', suffix)

# Used for sorting the records in order of descending newness.
def myTimeSortKey(record):
    key = record["EpochAdded"]
    if record["EpochFile"] > key:
        key = record["EpochFile"]
    return key

# Make a sensible publication date out of the kinds of date fields I have.
def makeSensiblePublicationDate(record):
    month = record["MonthPublished"]
    day = record["DayPublished"]
    year = record["YearPublished"]
    outString = ""
    if year != "":
        if month != "":
            if day != "":
                outString = month + "/" + day + "/" + year
            else:
                outString = month + "/" + year
        else:
            outString = year
    return outString

# Step 1:  Read the entire database into the lines[] array from stdin.
lines = sys.stdin.readlines()

# Step 2:  Parse each line in a way that reflects my comments about how the
# fields are defined, and append into an array records[].  The first line is
# skipped, since it contains the column headings.  However, we parse it anyway
# to determine if it has the right number of fields.
if len(lines) < 2 or len(lines[0].split('\t')) != 14:
    print("Database is empty or has wrong number of fields", file=sys.stderr)
    sys.exit(1)
globalError = False
records = []
for line in lines[1:]:
    fields = line.split('\t')
    # Make a default (empty) record for this line.
    record = {
        # Field 1
        "MonthAdded": "",
        "DayAdded": "",
        "YearAdded": "",
        "EpochAdded": 0,
        # Field 2
        "MonthPublished": "",
        "DayPublished": "",
        "YearPublished": "",
        # Field 3
        "DocumentNumbers": [],
        # Field 4
        "Revision": "",
        # Field 5
        "Portion": "",
        # Field 6
        "Authors": [],
        # Field 7
        "Targets": [],
        # Field 8
        "Keywords": [],
        # Field 9
        "URLs": [],
        # Field 10
        "Title": "",
        # Field 11
        "Archives": [],
        # Field 12
        "Sponsors": [],
        # Field 13
        "Disclaimer": "",
        # Field 14
        "Comment" : "",
        # Stuff that doesn't come from the database per se.
        "MonthFile": "",
        "DayFile": "",
        "YearFile": "",
        "SizeFile": "",
        "PathFile": "",
        "EpochFile": 0
    }
    # Now work on each field individually.
    if len(fields) >= 1:    # Field 1
        (illegal, month, day, year) = parseDate(fields[0], "20")
        globalError = globalError or illegal
        record["MonthAdded"] = month
        record["DayAdded"] = day
        record["YearAdded"] = year
        if month == "":
            month = 1
        if day == "":
            day = 1
        if year == "":
            year = 1970
        record["EpochAdded"] = time.mktime(date(int(year), int(month), int(day)).timetuple())
    if len(fields) >= 2:    # Field 2
        (illegal, month, day, year) = parseDate(fields[1], "19")
        globalError = globalError or illegal
        record["MonthPublished"] = month
        record["DayPublished"] = day
        record["YearPublished"] = year
    if len(fields) >= 3:    # Field 3
        if fields[2].strip() != "":
            DocumentNumbers = fields[2].split(",")
            for n in range(len(DocumentNumbers)):
                DocumentNumberFields = DocumentNumbers[n].strip().split("/") 
                if len(DocumentNumberFields) > 2:
                    print("Illegal document-number field: " + DocumentNumbers[n], 
                          file=sys.stderr)
                if len(DocumentNumberFields) == 0:
                    DocumentNumbers[n] = { 
                        "Number" : "", 
                        "Organization" : "" }
                elif len(DocumentNumberFields) == 1:
                    DocumentNumbers[n] = { 
                        "Number" : DocumentNumberFields[0].strip(), 
                        "Organization" : "" }
                else:
                    DocumentNumbers[n] = { 
                        "Number" : DocumentNumberFields[0].strip(), 
                        "Organization" : DocumentNumberFields[1].strip() }
            record["DocumentNumbers"] = DocumentNumbers
    if len(fields) >= 4:    # Field 4
        record["Revision"] = fields[3].strip()
    if len(fields) >= 5:    # Field 5
        record["Portion"] = fields[4].strip()
    if len(fields) >= 6:    # Field 6
        if fields[5].strip() != "":
            Authors = fields[5].split(",")
            for n in range(len(Authors)):
                AuthorFields = Authors[n].strip().split("/") 
                if len(AuthorFields) > 2:
                    print("Illegal author field: " + Authors[n], 
                          file=sys.stderr)
                if len(AuthorFields) == 0:
                    Authors[n] = { 
                        "Name" : "", 
                        "Organization" : "" }
                elif len(AuthorFields) == 1:
                    Authors[n] = { 
                        "Name" : AuthorFields[0].strip(), 
                        "Organization" : "" }
                else:
                    Authors[n] = { 
                        "Name" : AuthorFields[0].strip(), 
                        "Organization" : AuthorFields[1].strip() }
            record["Authors"] = Authors
    if len(fields) >= 7:    # Field 7
        record["Targets"] = simpleList(fields[6])
    if len(fields) >= 8:    # Field 8
        record["Keywords"] = simpleList(fields[7])
    if len(fields) >= 9:    # Field 9
        URLs = fields[8].split(",") 
        # Do some cleanup on the URLs.
        PathFile = ""
        fileSize = 0
        epoch = 0
        for n in range(len(URLs)):
            URLs[n] = URLs[n].strip()
            # Convert "http:" to "https:" where I know it's needed.
            if oldRemote == URLs[n][:lenOldRemote]:
                URLs[n] = remote + URLs[n][lenOldRemote:]
            # For all of the URLs which I can reinterpret as being files on my
            # local drive determine the file timestamp, and use the latest one.
            if remote == URLs[n][:lenRemote]:
                filePath = local + URLs[n][lenRemote:]
                index = filePath.find("#page=")
                if index > -1:
                    filePath = filePath[:index]
                filePath = filePath.replace("%20", " ").replace("%28", "(").replace("%29", ")")
                try:
                    stat = os.stat(filePath)
                    if True:
                        modTime = os.path.getmtime(filePath)
                    else:
                        modTime = stat.st_mtime
                    if modTime > epoch:
                        epoch = modTime
                        fileSize = stat.st_size
                        PathFile = filePath
                except:
                    print("Cannot read file " + filePath, file=sys.stderr)
        if epoch > 0:
            timestamp = time.localtime(epoch)
            record["YearFile"] = timestamp[0]
            record["MonthFile"] = "%02d" % timestamp[1]
            record["DayFile"] = "%02d" % timestamp[2]
            record["PathFile"] = PathFile
            record["SizeFile"] = fileSize
            record["EpochFile"] = epoch
        
        record["URLs"] = URLs
    if len(fields) >= 10:    # Field 10
        record["Title"] = fields[9].strip()
    if len(fields) >= 11:    # Field 11
        record["Archives"] = simpleList(fields[10])
    if len(fields) >= 12:    # Field 12
        record["Sponsors"] = simpleList(fields[11])
    if len(fields) >= 13:    # Field 13
        record["Disclaimer"] = fields[12].strip()
    if len(fields) >= 14:    # Field 14
        record["Comment"] = fields[13].strip()
        
    # Finish up this input line.
    records.append(record)

# Step 3:  Analyze records[] to determine what sections we will need in the
# output HTML, and the criteria for adding any given record to a section.  Note
# that there will always be a "Recent Additions" (or similarly-named) section,
# regardless of the targets and keywords defined in the database.

# Sort from newest (added) to oldest (added).
records.sort(reverse=True, key=myTimeSortKey)

#       TBD

# Step 4:  Output the HTML
currentEpoch = int(time.time())
cutoffMonths = 6
cutoffEpoch = currentEpoch - cutoffMonths * 30 * 24 * 3600
cutoffFiles = 25
print("<!DOCTYPE html>")
print("<html lang=\"en\">")
print("<head>")
print("<meta charset=\"utf-8\">")
print("<title>Auto-Generated List of Recent Virtual AGC Document Library Additions</title>")
print("</head>")
print("<body>")
print("<h1>Recent Additions to Virtual AGC Document Library as of %s</h1>" % (time.strftime("%m/%d/%Y", time.localtime(currentEpoch))))
print("<ul>")
for n in range(len(records)):
    record = records[n]
    epoch = myTimeSortKey(record)
    # Only show files for the last cutoffMonths, but if that's less than
    # cutoffFiles files, show some more.
    if epoch < cutoffEpoch and n >= cutoffFiles:
        break
    URLs = record["URLs"]
    print("<li>", end="")
    print(datetime.fromtimestamp(epoch).strftime("<b>%m/%d/%Y:</b> "), end="" )
    DocumentNumbers = record["DocumentNumbers"]
    if len(DocumentNumbers) > 0:
        print(DocumentNumbers[0]["Number"])
        if DocumentNumbers[0]["Organization"] != "":
            print(" (" + DocumentNumbers[0]["Organization"] + ")", end="")
        for m in range(1, len(DocumentNumbers)):
            print(", " + DocumentNumbers[m]["Number"], end="")
            if DocumentNumbers[m]["Organization"] != "":
                print(" (" + DocumentNumbers[m]["Organization"] + ")", end="")
        print(", ")
    print("\"<a href=\"" + URLs[0] + "\">", end="")
    print(record["Title"], end="")
    print("</a>\"", end="")
    for m in range(1, len(URLs)):
        print(" or <a href=\"" + URLs[m] + "\">here</a>", end="")
    published = makeSensiblePublicationDate(record)
    if published != "":
        print(", " + published, end="")
    if record["Revision"] != "":
        print(", " + record["Revision"], end="")
    if record["Portion"] != "":
        print(", " + record["Portion"], end="")
    if record["SizeFile"] != "":
        print(", " + friendlyFilesize(record["SizeFile"]), end="")
    Authors = record["Authors"]
    if len(Authors) > 0:
        print(", by " + Authors[0]["Name"], end="")
        if Authors[0]["Organization"] != "":
            print(" (" + Authors[0]["Organization"] + ")", end="")
        for m in range(1, len(Authors)):
            print(", " + Authors[m]["Name"], end="")
            if Authors[m]["Organization"] != "":
                print(" (" + Authors[m]["Organization"] + ")", end="")
    print(". ", end="")
    if record["Disclaimer"] != "":
        print(record["Disclaimer"], end="")
    print("</li>")
print("</ul>")
print("</body>")
print("</html>")

# Some debugging output
if False:
    for n in range(len(records)):
        record = records[n]
        if False:
            print(record)
        else:
            PathFile = record["PathFile"][lenLocal:]
            MonthFile = record["MonthFile"]
            DayFile = record["DayFile"]
            YearFile = record["YearFile"]
            SizeFile = record["SizeFile"]
            if PathFile != "":
                print("%s/%s/%s %s %s" % (MonthFile, DayFile, YearFile, SizeFile, PathFile))
            if record["Title"] != "":
                print("----------------------------------------------------")
                print(record["Title"])
                for m in range(len(record["Authors"])):
                    author = record["Authors"][m]
                    if author["Organization"] == "":
                        print("Author: " + author["Name"])
                    else:
                        print("Author: " + author["Name"] + " (" + author["Organization"] + ")")
                for m in range(len(record["DocumentNumbers"])):
                    DocumentNumber = record["DocumentNumbers"][m]
                    if DocumentNumber["Organization"] == "":
                        print("Document Number: " + DocumentNumber["Number"])
                    else:
                        print("Document Number: " + DocumentNumber["Number"] + " (" + DocumentNumber["Organization"] + ")")
                print("Portion=%s, Revision=%s" % (record["Portion"], record["Revision"]))
                print("URLs: " + str(record["URLs"]))
                print("File info: %s/%s/%s size=%s name=%s" % (record["MonthFile"], record["DayFile"], record["YearFile"], friendlyFilesize(record["SizeFile"]), record["PathFile"][lenLocal:]))
                print("Added: %s/%s/%s" % (record["MonthAdded"], record["DayAdded"], record["YearAdded"]))
                print("Published: %s/%s/%s" % (record["MonthPublished"], record["DayPublished"], record["YearPublished"]))
                print("Targets: " + str(record["Targets"]))
                print("Keywords: " + str(record["Keywords"]))
                print("Archives: " + str(record["Archives"]))
                print("Sponsors: " + str(record["Sponsors"]))
                print("Disclaimer: " + record["Disclaimer"])
                print("Epochs: File=%d Added=%d" % (record["EpochFile"], record["EpochAdded"]))