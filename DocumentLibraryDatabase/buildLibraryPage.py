#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPage.py
# Purpose:	     Builds a Virtual AGC Project "document library" web page from
#               a database of documents stored on the site. 
# Mod history:  2021-09-08 RSB  Began
#               2021-09-11 RSB  Added some database conveniences:  For the 
#                               Authors, the strings ", and " and " and "
#                               are now automatically replaced by ", ".
#                               Also, ", Jr" is replaced by " Jr".
#                               For the date fields, "MM/YYYY" and "YYYY"
#                               are now accepted, rather than insisting
#                               on "??/??/????".  I had already added
#                               the convenience of optional "M", "D", and "YY"
#                               rather than insisting on "??", "??", and "YYYY"
#               2021-09-12 RSB  Simplified the code for parsing simple lists
#                               and name/org lists, extended it to all 
#                               fields that could benefit from it, including
#                               handling of comma vs %44, slash vs %47,
#                               and ", Jr".
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
# the top line, which is a header).  Note that the the characters "," and "/"
# have a special meaning in terms of parsing certain fields into sub-fields, so
# if a any such sub-field (such as an author name or a document number) contains
# a "," or "/" unrelated to the desired sub-fields, they should be replaced
# by the strings "%44" and "%47", respectively.  As a convenience, the 
# suffixes ", Jr" and ", Sr" can be used directly in Author names or Scanner
# names without having to resort to "%44".  Also, "/" is a natural part of 
# URLs, so they needn't be replaced by "%47".
#
#   Field 1     Date Added.  This is an optional field of the form MM/DD/YYYY,
#               which indicates the date when the document file was added to
#               the library.  This used for automatically determining which
#               document files are newly added and therefore need to be
#               displayed to the user differently.  If the field is empty,
#               then the document file's filesystem timestamp is used instead.
#               Actually, we always use the later of the DateAdded and file
#               timestamps when collating, since obviously the file couldn't
#               have been added before it existed.
#
#   Field 2     Document Date.  This is supposed to reflect how the document
#               is internally dated.  The date format is one of the following,
#                   Year
#                   Month/Year
#                   Month/Day/Year
#               where Year is either YY or YYYY, Month is either M or MM, and
#               Day is either D or DD.  Also, any of these fields may consist
#               of question marks ("?", "??", "????"), which are then
#               automatically converted to one of the 3 patterns without 
#               question marks listed above.  A completely unknown date may
#               be entered as a single question mark.
#   Field 3     Document Number.  This is the document number originally assigned
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
#                   MSC or JSC  Manned Spacecraft Center
#                   GAEC        Grumman
#                   NAA         North American Aviation (or Rockwell)
#                   TRW         TRW
#                   IBM         IBM Federal Systems Division
#                   NASA        NASA other than MSC/JSC.
#                   Raytheon    Raytheon
#                   JPL         Jet Propulsion Laboratory
#                   Bellcomm
#                   Bendix
#               Note that the document numbers themselves cannot contain
#               '/' or ',', so if they do have those characters, remove or 
#               substitute them somehow.  My observation so far is that none
#               of the document numbers contain commas, and that only
#               about 0.1% of document numbers for Apollo contain a slash,
#               which I've simply replaced them with hyphens.
#
#   Field 4     Revision.  Empty for initial version or unknown.  I also 
#               sometimes put "Draft" or "Preliminary" as the revision level.
#
#   Field 5     Portion.  If the file contains the entire document, 
#               blank. But the file may be one of a multivolume set, or just 
#               some range of sections, or just a table, or some other portion 
#               of the entire document.  In that case, this field is a very 
#               concise description of the portion.
#               
#   Field 6     Authors.  If unknown, may be left blank, but I usually use
#               "Anonymous", simply as a maintenance feature to emphasize that
#               I actually checked it rather than just accidentally omitted
#               it.  If there are multiple authors,
#               they can be comma-delimited.  If the authors are a part of 
#               some known organization, that affiliation can be appended with
#               a "/".  For example "Hugh Blair-Smith/IL, Jay Sampson/AC".
#               Note that names must not contain commas, since commas delimit
#               the names; however, ", Jr" is an exception for 
#               convenience, in that it will be accepted without causing a 
#               break in the name.  Beyond that, "%44" can be placed within
#               a name, and will automatically be replaced by a ",".  For
#               example, "%44 Sr." in place of ", Sr.".
#               Also, if individual authors aren't listed
#               in the document, but the organization which created it can
#               be used as the author; for example, "MIT Instrumentation 
#               Laboratory", "AC Electronics", and so on.  Where the 
#               organization names changed over the course of the project
#               ("MIT Instrumentation Laboratory" becoming "Charles Stark
#               Draper Laboratory", "AC Electronics" perhaps appearing as
#               "Delco Electronics" or even "General Motors", "Manned 
#               Spacecraft Center" becoming "Johnson Space Center", etc.) I
#               generally just continue to use the one that came first or was
#               more commonly used.
#               
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
#               Note that URLs must not contain commas, since commas delimit
#               the URL lists.  If a URL does contain a comma, replace it
#               with "%44"; the software will automatically convert this back
#               to a comma without it affecting how the URL lists are broken
#               up.  The actual URL in a hyperlink will have a comma.
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

# Here are various HTML blurbs that head up individual sections of the 
# document we're going to output.

blurbTop = """ 
This is our collection of all documentation we've managed to
collect over the decades that bears even a passing relevance to the 
spaceborne guidance computers used in the Apollo and Gemini programs ... or at
least all of the documentation I think I'm legally able to give you.  Some 
hints as to where to find such documentation on your own can be found on our
<a href="https://www.ibiblio.org/apollo/QuestForInfo.html">Documentation
Quest page</a>.  Our <a href="https://www.ibiblio.org/apollo/faq.html">FAQ
page</a> also points out various significant Apollo-centric websites from
which we've taken some documentation, in order to centralize it.
<br><br>
When we're in possession of high-resolution scans, it's our practice to provide
only a reduced-quality but legible version here, but to provide the full
resolution data at <a href="https://archive.org/details/virtualagcproject">
our Internet Archive site</a>.  On this page, the links for both are 
provided.  In general, when any given document has multiple hyperlinks listed,
the <i>first</i> of the links is the recommended one, and the second or third
links provided are generally either much larger downloads, or else are much
lower quality scans.
<br><br>
Finally, while the available documents are provided below in a form which we 
think is relatively convenient, we also usually have more information about
the downloads than we care to clutter up your screen with.  For example, we
have the sizes of the downloads, and sometimes the names of the archives from
which we extracted the documents, as well as the name of the person who either
did the scanning for us or else financially supported the scanning process.
You can see this supplemental information by hovering your mouse over a
hyperlink before clicking the link.  Unfortunately, that <i>only</i> works if
you have a mouse rather than a touchscreen; but that's life!
"""

blurbDebug = """
This section is present temporarily, only for the purpose of debugging.  It
will be removed before this auto-generated page goes live in production.
Right now, it simply lists every document in the library, in the same order
found on <a href="https://www.ibiblio.org/apollo/links.html">our 
previously-existing Document Library page ... at least to the extent that
I've input the data.</a>
"""

blurbRecentlyAdded = """
This section lists all documents added or changed in the preceding 6-month
period, with the most-recently-added documents at the top of the list, and
the least-recently-added ones at the bottom.
"""

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
        if len(dateFields) == 1:
            dateFields = ["??", "??", dateFields[0]]
        elif len(dateFields) == 2:
            dateFields = [dateFields[0], "??", dateFields[1]]
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
        array[n] = array[n].strip().replace("%44", ",")
    return array

# Parse a comma-delimited list in which the fields are '/'-delimited pairs.
# The name input parameter will be "Number" for Document Numbers and "Name"
# for Authors.
def orgList(field, name):
    array = simpleList(field)
    for n in range(len(array)):
        subFields = array[n].split('/')
        for m in range(len(subFields)):
            subFields[m] = subFields[m].replace("%47", "/")
        array[n] = { name : "", "Organization" : "" }
        if len(subFields) > 0:
            array[n][name] = subFields[0]
        if len(subFields) > 1:
            array[n]["Organization"] = subFields[1]
        if len(subFields) > 2:
            print("Illegal field: " + array[n], file=sys.stderr)
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

# What this function does is to take something like NA, where N represents
# any string of 0-10 digits and A is any string of 0-10 characters with a 
# leading non-digit, and to pad it so that N is left-padded with '0' and 
# A is left-padded with ' '.  The idea is to normalize strings like "34A",
# "568", and 129FJ so that they sort in a way we'd expect:  first, numerically
# on N, and then stringily on A.
def padDocNumberField(n):
    m = "0000000000"
    while n[:1].isdigit():
        m = m[1:] + n[:1]
        n = n[1:]
    return m + "%10s" % n

# Used for sorting the records in order of document numbers.  We assume
# in this case that the first document number in a record that we encounter
# having the form "something#number" is what we want to use to sort on 
# numbers.
def myDocSortKeyRaw(record, reverse):
    dn = ""
    for documentNumber in record["DocumentNumbers"]:
        if "#" not in documentNumber["Number"]:
            continue
        fields = documentNumber["Number"].split("#")
        if len(fields) == 2:
            fields2 = fields[1].split("-")
            if len(fields2) == 1:
                dn = padDocNumberField("")
                n = padDocNumberField(fields2[0])
            elif reverse:
                dn = padDocNumberField(fields2[0])
                n = padDocNumberField(fields2[1])
            else:
                dn = padDocNumberField(fields2[1])
                n = padDocNumberField(fields2[0])
            dn += n
            break
    return dn
def myDocSortKey(record):
    return myDocSortKeyRaw(record, False)
def myDocSortKeyReverse(record):
    return myDocSortKeyRaw(record, True)

def myXdeSortKey(record):
    dn = ""
    for documentNumber in record["DocumentNumbers"]:
        fields = documentNumber["Number"].split("-")
        if len(fields) == 4 and fields[0] == "XDE":
            dn = fields[0] + "-" + fields[1] + "-" + fields[2] + "-"
            dn += padDocNumberField(fields[3])
            break
    return dn

# Sort key for database order.
def myOriginalSortKey(record):
    return record["lineNumber"]

# Sort key for document titles.
def myTitleSortKey(record):
    return record["Title"]

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

# Uses info from the document record to create a "mouse hover" (using the title
# attribute of the href) to show supplemental data about a file for download.
# Idea is that while there's some info that could be valuable to see 
# occasionally, it's not worth cluttering up the main page all the time.
def makeHover(record, n):
    Archives = record["Archives"]
    Sponsors = record["Sponsors"]
    SizeFiles = record["SizeFiles"]
    hover = ""
    if len(SizeFiles) > n and SizeFiles[n] != 0:
        hover += "File size: " + friendlyFilesize(SizeFiles[n]) + ". "
    if len(Sponsors) > n and Sponsors[n] != "":
        hover += "Scanned by: " + Sponsors[n] + ". "
    if len(Archives) > n and Archives[n] != "":
        hover += "Archived by: " + Archives[n] + "."
    if hover != "":
        hover = "title=\"" + hover[:-1] + "\""
    return hover

# Create the HTML string for printing out a document entry. So to change
# how documents are displayed, it's only necessary to modify or replace
# this one function.
def documentEntryHTML(record, showComment):    
    html = ""
    URLs = record["URLs"]
    DocumentNumbers = record["DocumentNumbers"]
    if len(DocumentNumbers) > 0:
        html += DocumentNumbers[0]["Number"]
        if DocumentNumbers[0]["Organization"] != "":
            html += " (" + DocumentNumbers[0]["Organization"] + ")"
        for m in range(1, len(DocumentNumbers)):
            html += ", " + DocumentNumbers[m]["Number"]
            if DocumentNumbers[m]["Organization"] != "":
                html += " (" + DocumentNumbers[m]["Organization"] + ")"
        html += ", "
    if record["Revision"] != "":
        html += record["Revision"] + ", "
    if record["Portion"] != "":
        html += record["Portion"] + ", "
    if "Video" in record["Keywords"]:
        html += "Video, "
    if "Transcript" in record["Keywords"]:
        html += "Transcript, "
    if "Audio" in record["Keywords"]:
        html += "Audio, "
    if "Photo" in record["Keywords"]:
        html += "Photograph, "
    if len(URLs) > 0:
        hover = makeHover(record, 0)
        html += "\"<a " + hover + " href=\"" + URLs[0] + "\">"
        html += record["Title"]
        html += "</a>\""
        for m in range(1, len(URLs)):
            hover = makeHover(record, m)
            html += " or <a " + hover + " href=\"" + URLs[m] + "\">here</a>"
    else:
        html += record["Title"]
    published = makeSensiblePublicationDate(record)
    if published != "":
        html += ", " + published
    Authors = record["Authors"]
    if len(Authors) > 0:
        html += ", by " + Authors[0]["Name"]
        if Authors[0]["Organization"] != "":
            html += " (" + Authors[0]["Organization"] + ")"
        for m in range(1, len(Authors)):
            html += ", " + Authors[m]["Name"]
            if Authors[m]["Organization"] != "":
                html += " (" + Authors[m]["Organization"] + ")"
    if html != "":
        html += ". "
    if record["Disclaimer"] != "":
        html += record["Disclaimer"]
        while html[-1:] == " ":
            html = html[:-1]
        if html[-1:] not in [".", "!", "?"]:
            html += ". "
    if showComment and record["Comment"] != "":
        html += record["Comment"]
        while html[-1:] == " ":
            html = html[:-1]
        if html[-1:] not in [".", "!", "?"]:
            html += ". "
    if html != "" and len(URLs) == 0:
        html = "<span style=\"color:#808080\">" + html + "</span>"
    return html

# The following list determines how to divide the page up into sections.
# Items are chosen for the sections based on the parameters in the table,
# and on document-specific data in the database, such as document numbers,
# targets, and keywords. The parameters targets[] and keywords[] are simply
# lists of targets and keywords that may appear in the database, and an item
# is included in the section if there is any overlap.  The DocumentNumbers[]
# parameters, on the other hand, try to match only the leading portions of
# strings.  The anchor field must have a matching <a name="..."></a> tag.
# Only entries with an "anchor" key are used in the table of contents.
# Never remove the 1st two entries below, but the "anchor" can be removed
# to disable either of the first 2 entries.  If restored, the anchors must
# be "Debug" and "RecentAdditions" precisely.
tableOfContentsSpec = [
    { "anchor" : "Debug", "title" : "Debug", "sortKey" : myOriginalSortKey, "blurb" : blurbDebug },
    { "anchor" : "RecentAdditions", "title" : "Recently Added", "sortKey" : myTimeSortKey, "sortReverse" : True, "blurb" : blurbRecentlyAdded },
    { "anchor" : "Presentation", "title" : "Presentations", "sortKey" : myTitleSortKey, "keywords" : ["Presentation"] },
    { "title" : "AGC Software Language Manuals", "keywords" : ["AGC Language"] },
    { "title" : "Program Listings", "keywords" : ["AGC Listing", "AGS Listing", "LVDC Listing", "OBC Listing"] },
    { "anchor" : "SGAMemos", "title" : "Space Guidance Analysis Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Space Guidance Analysis Memo"] },
    { "anchor" : "ApolloProjectMemos", "title" : "Apollo Project Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Apollo Project Memo"] },
    { "anchor" : "ApolloEngineeringMemos", "title" : "Apollo Engineering Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Apollo Engineering Memo"] },
    { "anchor" : "DigitalDevelopmentMemos", "title" : "Digital Development Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Digital Development Memo"] },
    { "anchor" : "ElectronicDesignGroupMemos", "title" : "Electronic Design Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Electronic Design Group Memo"] },
    { "anchor" : "ISSMemos", "title" : "Inertial Sub-System (I.S.S.) Memos", "sortKey" : myDocSortKeyReverse, "documentNumbers" : ["ISS Memo"] },
    { "anchor" : "XDENotes", "title" : "XDE Notes", "sortKey" : myXdeSortKey, "documentNumbers" : ["XDE-"] },
    { "anchor" : "DigitalGroupMemos", "title" : "Digital Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["DG Memo"] },
    { "anchor" : "MissionTechniquesMemos", "title" : "Mission Techniques Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Mission Techniques Memo"] },
    { "anchor" : "SystemTestGroupMemos", "title" : "System Test Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["System Test Group Memo"] },
    { "anchor" : "LuminaryMemos", "title" : "LUMINARY Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["LUMINARY Memo"] },
    { "anchor" : "ColossusMemos", "title" : "COLOSSUS Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["COLOSSUS Memo"] },
    { "anchor" : "SkylarkMemos", "title" : "SKYLARK (SKYLAB) Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["SKYLARK Memo", "SKYLAB Memo"] }
]

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
lineNumber = 1
for line in lines[1:]:
    fields = line.split('\t')
    # Make a default (empty) record for this line.
    record = {
        "lineNumber" : lineNumber,
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
        "SizeFiles": [],
        "MonthFile": "",
        "DayFile": "",
        "YearFile": "",
        "PathFile": "",
        "EpochFile": 0
    }
    lineNumber += 1
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
            record["DocumentNumbers"] = orgList(fields[2], "Number") 
    if len(fields) >= 4:    # Field 4
        record["Revision"] = fields[3].strip()
    if len(fields) >= 5:    # Field 5
        record["Portion"] = fields[4].strip()
    if len(fields) >= 6:    # Field 6
        if fields[5].strip() != "":
            field5 = fields[5].replace(", and ", ", ").replace(" and ", ", ").replace(", Jr", "%44 Jr")
            record["Authors"] = orgList(field5, "Name")            
    if len(fields) >= 7:    # Field 7
        record["Targets"] = simpleList(fields[6])
    if len(fields) >= 8:    # Field 8
        record["Keywords"] = simpleList(fields[7])
    if len(fields) >= 9:    # Field 9
        URLs = simpleList(fields[8])
        # Do some cleanup on the URLs.
        PathFile = ""
        fileSizes = []
        epoch = 0
        for n in range(len(URLs)):
            fileSizes.append(0)
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
                    fileSizes[n] = stat.st_size
                    if True:
                        modTime = os.path.getmtime(filePath)
                    else:
                        modTime = stat.st_mtime
                    if modTime > epoch:
                        epoch = modTime
                        PathFile = filePath
                except:
                    print("Cannot read file " + filePath, file=sys.stderr)
        record["SizeFiles"] = fileSizes
        if epoch > 0:
            timestamp = time.localtime(epoch)
            record["YearFile"] = timestamp[0]
            record["MonthFile"] = "%02d" % timestamp[1]
            record["DayFile"] = "%02d" % timestamp[2]
            record["PathFile"] = PathFile
            record["EpochFile"] = epoch
        
        record["URLs"] = URLs
    if len(fields) >= 10:    # Field 10
        record["Title"] = fields[9].strip()
    if len(fields) >= 11:    # Field 11
        record["Archives"] = simpleList(fields[10].replace(", Jr", "%44 Jr"))
    if len(fields) >= 12:    # Field 12
        record["Sponsors"] = simpleList(fields[11].replace(", Jr", "%44 Jr"))
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

# Step 4:  Output the HTML file header.
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

# Step 5:  Output the HTML body.

print(blurbTop)
print("<h1>Table of Contents</h1>")
print("<ul>")
for n in range(len(tableOfContentsSpec)):
    if "anchor" in tableOfContentsSpec[n]:
        print("<li>")
        print("<a href=\"#" + tableOfContentsSpec[n]["anchor"] + "\">")
        print(tableOfContentsSpec[n]["title"])
        print("</a>")
        print("</li>")
print("</ul>")

# Step 5@:  Just for testing, complete output, in the same order
# as database entry ... which the way I've been doing it, is almost exactly
# the same as the old links.html page.
if "anchor" in tableOfContentsSpec[0] and tableOfContentsSpec[0]["anchor"] == "Debug":
    print("<a name=\"Debug\"></a>")
    print("<h1>Entire Document Library in Database Order as of %s</h1>" % (time.strftime("%m/%d/%Y", time.localtime(currentEpoch))))
    print(blurbDebug)
    print("<ol>")
    records.sort(key=tableOfContentsSpec[0]["sortKey"])
    for n in range(len(records)):
        html = documentEntryHTML(records[n], True)
        if html != "":
            print("<li>", end="")
            print(html, end="")    
            print("</li>")
    print("</ol>")

# Step 5A:  "Recent Additions" section.
if "anchor" in tableOfContentsSpec[1] and tableOfContentsSpec[1]["anchor"] == "RecentAdditions":
    print("<a name=\"RecentAdditions\"></a>")
    print("<h1>Recent Additions to Virtual AGC Document Library as of %s</h1>" % (time.strftime("%m/%d/%Y", time.localtime(currentEpoch))))
    print(blurbRecentlyAdded)
    print("<ul>")
    records.sort(reverse=True, key=tableOfContentsSpec[1]["sortKey"])  # Sort from newest (added) to oldest (added).
    for n in range(len(records)):
        record = records[n]
        epoch = myTimeSortKey(record)
        # Only show files for the last cutoffMonths, but if that's less than
        # cutoffFiles files, show some more.
        if epoch < cutoffEpoch and n >= cutoffFiles:
            break
        print("<li>", end="")
        print(datetime.fromtimestamp(epoch).strftime("<b>%m/%d/%Y:</b> "), end="" )
        print(documentEntryHTML(record, False), end="")    
        print("</li>")
    print("</ul>")

# Step 5B:  Output all other sections, based on the parameters in 
# tableOfContentsSpec[].  
for n in range(2, len(tableOfContentsSpec)):
    if "anchor" not in tableOfContentsSpec[n]:
        continue
    print("<a name=\"" + tableOfContentsSpec[n]["anchor"] + "\"></a>")
    print("<h1>" + tableOfContentsSpec[n]["title"] + "</h1>")
    if "blurb" in tableOfContentsSpec[n]:
        print(tableOfContentsSpec[n]["blurb"])
    print("<ul>")
    records.sort(key=tableOfContentsSpec[n]["sortKey"])
    keywordsSet = set([])
    targetsSet = set([])
    documentNumbers = []
    if "keywords" in tableOfContentsSpec[n]:
        keywordsSet = set(tableOfContentsSpec[n]["keywords"])
    if "targets" in tableOfContentsSpec[n]:
        targetsSet = set(tableOfContentsSpec[n]["targets"])
    if "documentNumbers" in tableOfContentsSpec[n]:
        documentNumbers = tableOfContentsSpec[n]["documentNumbers"]
    for record in records:
        matched = False
        if len(list(keywordsSet & set(record["Keywords"]))) > 0:
            matched = True
        elif len(list(targetsSet & set(record["Targets"]))) > 0:
            matched = True
        else:
            for documentNumberA in documentNumbers:
                if matched:
                    break
                for documentNumberB in record["DocumentNumbers"]:
                    if matched:
                        break
                    if documentNumberB["Number"].startswith(documentNumberA):
                        matched = True
        if matched:
            print("<li>" + documentEntryHTML(record, True) + "</li>")
    print("</ul>")

# Final step: Cleanup.
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
            SizeFiles = record["SizeFiles"]
            if PathFile != "":
                print("%s/%s/%s %s" % (MonthFile, DayFile, YearFile, PathFile))
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
                print("File info: %s/%s/%s name=%s" % (record["MonthFile"], record["DayFile"], record["YearFile"], record["PathFile"][lenLocal:]))
                print("Added: %s/%s/%s" % (record["MonthAdded"], record["DayAdded"], record["YearAdded"]))
                print("Published: %s/%s/%s" % (record["MonthPublished"], record["DayPublished"], record["YearPublished"]))
                print("Targets: " + str(record["Targets"]))
                print("Keywords: " + str(record["Keywords"]))
                print("Archives: " + str(record["Archives"]))
                print("Sponsors: " + str(record["Sponsors"]))
                print("Disclaimer: " + record["Disclaimer"])
                print("Epochs: File=%d Added=%d" % (record["EpochFile"], record["EpochAdded"]))