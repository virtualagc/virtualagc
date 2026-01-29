#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPage.py
# Purpose:	    Builds a Virtual AGC Project "document library" web page from
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
#                               and ", Jr".  More importantly, it's actually
#                               generating a lot more of the web-page now.
#               2021-09-20 RSB  First fully-functional version, I think.
#               2021-10-27 RSB  Added "ACB-" document-number prefix for 
#                               ACB requests.
#               2022-01-18 RSB  Added the Study Guides section.
#               2022-07-03 RSB  Tracked whether or not items are categorized
#                               (as opposed to merely appearing in the 
#                               Everything section).
#		        2022-10-29 RSB	Expanded "Software Listings" section to 
#				                "Software Listings and Dumps".
#		        2022-11-01 RSB	Added --shuttle command-line switch to 
#				                process shuttle documents rather than
#				                main document library.
#               2022-11-23 RSB  Added the "Administrative" section to the 
#                               Shuttle library.
#               2022-11-28 RSB  Added OI-specific sections to the Shuttle
#                               library.
#               2023-07-31 RSB  Added shorthand STS-nnn-mmm to Targets field.
#               2023-08-01 RSB  Added the "Flight STS-xxx" sections for --shuttle.
#               2023-11-24 RSB  Corrected many STS flight titles.
#               2024-02-28 RSB  Added section for flight software
#                               user notes and requirements waivers.
#               2025-02-05 RSB  For reasons no longer clear to me, I was always
#                               converting the first letter of the document
#                               "portion" to lower case; that was not a good 
#                               idea.
#               2026-01-28 RSB  Added --probes, and refactored so that the
#                               Apollo, Shuttle, and Probes libraries are
#                               processed by separate modules.
#
# Usage:
#	./buildLibraryPage.py <DocumentLibraryDatabase.tsv >../links2.html
# or
#	./buildLibraryPage.py --shuttle <ShuttleLibraryDatabase.tsv >../links-shuttle.html
# or
#   ./buildLibraryPage.py --probes <ProbesLibraryDatabase.tsv >../links-probes.html
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
#                   MSC         Manned Spacecraft Center or Johnson Space Center
#                   GAEC        Grumman
#                   NAA         North American Aviation (or Rockwell)
#                   TRW         TRW
#                   IBM         IBM Federal Systems Division
#                   NASA        NASA other than MSC
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
#               it.  If there are multiple authors, they can be 
#               comma-delimited.  If the authors are a part of 
#               some known organization, that affiliation can be appended with
#               a "/".  For example "Hugh Blair-Smith/IL, Jay Sampson/AC".
#               Actually, every individual should have an affiliation, even
#               if it's just "/" followed by nothing, and no corporate author
#               (such as "MIT Instrumentation Laboratory") should have an
#               affiliation.  That's because we use the affiliation to 
#               recognize which authors are individuals and which are 
#               corporates, and that affects sorting on author names.
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
#               The keyword "Blurb" is special. The entire record is always
#               ignored, except when printing out the "Recent Additions" 
#               section.  There, the Comment field is used as a blurb for that
#               day's sub-section. 
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
#               up.  The actual URL in a hyperlink will have a comma.  There
#               are some factors built in for my own personal convenience,
#               in that "http://www.ibiblio.org/" and "^.*/sandroid.org/public_html/"
#               are both automatically replaced by "https://www.ibiblio.org/";
#               That so that I can cut-and-paste URLs from existing web pages
#               or from my local document stash without having to correct them
#               for onlin use.
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
#		        document (paid for with our tax dollars) was nil,
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
#
#   Field 15    If the document is a scan of a software listing, this field
#               can be used as a URL for the transcription to source file(s)
#               in the github repo.
#
#   Field 16    Similarly, this field could be a URL for the assembly listing
#               output by the "modern" assembler.
#
#   Field 17    And similarly, this field could be the URL for the
#               colorized, syntax-highlighted HTML of the assembly listing.
#
#   Field 18    In cases where we have a core dump of software without having
#               source code, this field can contain a URL to the core dump
#               (typically in our github repo).

import sys
import os
import time
from datetime import datetime, date
import re
from buildLibraryPageCommon import *

apollo = True
shuttle = False
probes = False
for param in sys.argv[1:]:
    if param == "--shuttle":
        apollo = False
        shuttle = True
        probes = False
    elif param == "--probes":
        apollo = False
        shuttle = False
        probes = True
if apollo:
    from buildLibraryPageApollo import *
elif shuttle:
    from buildLibraryPageShuttle import *
elif probes:
    from buildLibraryPageProbes import *
else:
    sys.exit(1)
    

oldRemote = "http://www.ibiblio.org/apollo/"
remote = "https://www.ibiblio.org/apollo/"
local = "/home/rburkey/Desktop/sandroid.org/public_html/apollo/"
lenOldRemote = len(oldRemote)
lenRemote = len(remote)
lenLocal = len(local)

fancyHeaderAndFooter = True

fileHeader = """<!DOCTYPE doctype PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Virtual AGC Document Library Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name=Author content="Ronald Burkey">
<link rel=icon type="image/png" href="favicon.png">
<meta name=author content="Ronald S. Burkey">
<script type="text/javascript" src="Header.js"></script>
</head>
<body style="background-image: url(gray3.jpg);">
<script type="text/javascript">
document.write(headerTemplate.replace("@TITLE@","Document Library").replace("@SUBTITLE@","%s"))
</script>
<br><br>
""" % title

fileFooter = """
<br>
<hr style="width: 100%; height: 2px;">
<center><br><span style=
"color: rgb(84, 89, 93); font-family: sans-serif; font-size: 11.05px; 
font-style: normal; font-variant: normal; font-weight: normal; 
letter-spacing: normal; line-height: 16.575px; orphans: auto; 
text-align: center; text-indent: 0px; text-transform: none; 
white-space: normal; widows: 1; word-spacing: 0px; 
-webkit-text-stroke-width: 0px; display: inline !important; 
float: none; background-color: rgb(255, 255, 255);">
This page is available under the 
<a href="https://creativecommons.org/publicdomain/zero/1.0/">
Creative Commons No Rights Reserved License</a>
</span><br><i><font size="-1">Last modified by <a href=
"mailto:info@sandroid.org">Ronald Burkey</a> on """ + currentDateString + """
<br><br>
<a href="https://www.ibiblio.org">
<img style="border: 0px solid ; width: 300px; height: 100px;" alt=
"Virtual AGC is hosted by ibiblio.org" src="hosted.png" height=
"100" width="300"></a><br></font></i></center><br></body></html>
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
            if subFields[1] == "":
                subFields[1] = "_"
            array[n]["Organization"] = subFields[1]
        if len(subFields) > 2:
            print("Illegal field: " + str(array[n]), file=sys.stderr)
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
    return outString, year

# Uses info from the document record to create a "mouse hover" (using the title
# attribute of the href) to show supplemental data about a file for download.
# Idea is that while there's some info that could be valuable to see 
# occasionally, it's not worth cluttering up the main page all the time.
archiveAbbreviations = {
    "NARA-SW" : "National Archives and Records Administration, Fort Worth Branch",
    "UHCL" : "University of Houston &mdash; Clear Lake, JSC History Collection",
    "NTRS" : "NASA Technical Reports Server",
    "KLABS" : "NASA Office of Logic Design Website",
    "UAH" : "University of Alabama in Huntsville"
}
def makeTitleHover(record, n):
    Archives = record["Archives"]
    Sponsors = record["Sponsors"]
    SizeFiles = record["SizeFiles"]
    hover = ""
    if len(SizeFiles) > n and SizeFiles[n] != 0:
        hover += "File size: " + friendlyFilesize(SizeFiles[n]) + ". "
    if len(Sponsors) > n and Sponsors[n] != "":
        hover += "Processing: " + Sponsors[n] + ". "
    if len(Archives) > n and Archives[n] != "":
        archive = Archives[n]
        if archive in archiveAbbreviations:
            archive = archiveAbbreviations[archive]
        hover += "Archiving: " + archive + "."
    if hover != "":
        # I tried the following, to indicate to the user that there's some
        # additional hover information available ... but it was just nasty,
        # so I've eliminated it.
        #hover = "style=\"background-color:" + hoverColor + "\" title=\"" + hover[:-1] + "\""
        hover = "title=\"" + hover[:-1] + "\""
    return hover

# Makes a hover containing the organizational affiliation for a document
# number or author dictionary.
orgAbbreviations = { 
    "IL" : "MIT Instrumentation lab (AKA Charles Stark Draper Laboratory)",
    "AC" : "AC Electronics (AKA AC Sparkplug, Delco Electronics, etc.)",
    "MSC" : "Manned Spacecraft Center (AKA Johnson Space Center)",
    "GAEC" : "Grumman Aerospace Engineering",
    "NAA" : "North American Aviation (AKA North American Rockwell AKA Rockwell International)",
    "TRW" : "TRW (AKA Thompson Ramo Wolldridge)",
    "IBM" : "IBM Federal Systems Division",
    "NASA" : "National Aeronautics and Space Administration (other than MSC)",
    "JPL" : "Jet Propulsion Laboratory",
    "Douglas" : "McDonnell Douglas",
    "USA" : "United Space Alliance",
    "Intermetrics" : "Intermetrics Incorporated",
    "Rockwell" : "Rockwell International",
    "DOD" : "United Stated Department of Defense",
    "UT" : "University of Texas at Austin",
    "UTC" : "United Technologies Corporation, Hamilton Standard Division",
    "GE" : "General Electric",
    "JHU-APL" : "Johns Hopkins University - Applied Physics Lab",
    "PE" : "Perkin-Elmer Corporation",
    "Caltech" : "California Institute of Technology"
}
def makeOrgHover(dict):
    hover = ""
    endHover = ""
    if "Organization" in dict and dict["Organization"] not in [ "", "_" ]:
        endHover = "</span>"
        org = dict["Organization"]
        if org in orgAbbreviations:
            org = orgAbbreviations[org]
        hover = "<span style=\"background-color:" + hoverColor + "\" title=\"Affiliation: " + org + "\">"
    return (hover, endHover)

# Create the HTML string for printing out a document entry. So to change
# how documents are displayed, it's only necessary to modify or replace
# this one function.
useOrgHover = True
def addOrg(dict):
    html = ""
    if "Name" in dict:
        nameNumber = dict["Name"]
    else:
        nameNumber = dict["Number"]
    html += "<code>"
    if useOrgHover:
        (hover, endHover) = makeOrgHover(dict)
        html += hover + nameNumber + endHover
    else:
        html += nameNumber
        if dict["Organization"] not in [ "", "_" ]:
            html += " (" + dict["Organization"] + ")"
    html += "</code>"
    return html

hrForYearChange = False
lastYear = ""
firstEntry = True
everything = False
def documentEntryHTML(record, showComment):  
    global lastYear, firstEntry
    html = ""
    if "recent" in record and record["recent"]:
        html = "<img src=\"new.png\">"
    if everything and ("Categorized" not in record or not record["Categorized"]):
        html += frowny
    URLs = record["URLs"]
    DocumentNumbers = record["DocumentNumbers"]
    target = ""
    for documentNumber in DocumentNumbers:
        if documentNumber["Number"].lower()[:4] in ["pcr-", "pcn-"]:
            keywords = str(record["Keywords"]).lower()
            if "sundance" in keywords:
                target += ", SUNDANCE"
            if "luminary" in keywords:
                target += ", LUMINARY"
            if "artemis" in keywords or "comanche" in keywords or "colossus" in keywords:
                target += ", COLOSSUS"
            if "skylark" in keywords:
                target += ", SKYLARK"
            if "sundisk" in keywords:
                target += ", SUNDISK"
            if target[:2] == ", ":
                target = target[2:]
            if target != "":
                html += "(" + target + ") "
            break
            
    if len(DocumentNumbers) > 0:
        html += addOrg(DocumentNumbers[0])
        for m in range(1, len(DocumentNumbers)):
            html += ", " + addOrg(DocumentNumbers[m])
        html += ", "
    if record["Revision"] != "":
        html += record["Revision"] + ", "
    if "video" in record["Keywords"]:
        html += "Video, "
    if "transcript" in record["Keywords"]:
        html += "Transcription, "
    if "audio" in record["Keywords"]:
        html += "Audio, "
    if "photo" in record["Keywords"]:
        html += "Photography, "
    if len(URLs) > 0:
        hover = makeTitleHover(record, 0)
        html += "\"<a " + hover + " href=\"" + URLs[0] + "\">"
        html += record["Title"]
        html += "</a>\""
        for m in range(1, len(URLs)):
            hover = makeTitleHover(record, m)
            html += " or <a " + hover + " href=\"" + URLs[m] + "\">here</a>"
    else:
        html += "\"" + record["Title"] + "\""
    if record["Portion"] != "":
        portion = record["Portion"]
        #portion = portion[:1].lower() + portion[1:]
        html += ", " + portion
    published,year = makeSensiblePublicationDate(record)
    if hrForYearChange:
        if not firstEntry and year != lastYear:
            html = "<hr>" + html
        firstEntry = False
        lastYear = year
    if published != "":
        html += ", " + published
    else:
        html += " (not dated)"
    Authors = record["Authors"]
    if len(Authors) > 0:
        html += ", by " + addOrg(Authors[0])
        for m in range(1, len(Authors)):
            html += ", " + addOrg(Authors[m])
    if html != "" and html[-1:] not in [".", "!", "?"] and html[-15:] not in [ ".</span></code>", "?</span></code>", "!</span></code>" ]:
        html += ". "
    if record["Disclaimer"] != "":
        html += "Disclaimer: " + record["Disclaimer"]
        while html[-1:] == " ":
            html = html[:-1]
        if html[-1:] not in [".", "!", "?"]:
            html += ". "
    if showComment and record["Comment"] != "":
        html += record["Comment"]
        while html[-1:] == " ":
            html = html[:-1]
        if html[-1:] not in [".", "!", "?", ">"]:
            html += ". "
    if record["TranscriptionURL"] != "" or record["AssemblyListingURL"] != "" or record["ColorizedURL"] != "" or record["CoreDumpURL"] != "":
        if html[-1:] != ">":
            html += "<br>"
        html += "<blockquote><i>See also:</i><ul>"
        if record["TranscriptionURL"] != "":
            html += "<li><a href=\"" + record["TranscriptionURL"] + "\">Machine-friendly, assemblable source-code files.</a></li>"
        if record["AssemblyListingURL"] != "":
            html += "<li><a href=\"" + record["AssemblyListingURL"] + "\">Listing created by assembling the source-code file(s).</a></li>"
        if record["ColorizedURL"] != "":
            html += "<li><a href=\"" + record["ColorizedURL"] + "\">Human-friendly, colorized, syntax-highlighted assembly listing.</a></li>"
        if record["CoreDumpURL"] != "":
            html += "<li><a href=\"" + record["CoreDumpURL"] + "\">Core-rope contents dumped from physical memory modules.</a></li>"
        html += "</ul></blockquote>"
    if html != "" and len(URLs) == 0 and record["TranscriptionURL"] == "" and record["AssemblyListingURL"] == "" and record["ColorizedURL"] == "" and record["CoreDumpURL"] == "":
        html = "<span style=\"color:#808080\">" + html + "</span>"
    return html

# Step 1:  Read the entire database into the lines[] array from stdin.
lines = sys.stdin.readlines()

# Step 2:  Parse each line in a way that reflects my comments about how the
# fields are defined, and append into an array records[].  The first line is
# skipped, since it contains the column headings.  However, we parse it anyway
# to determine if it has the right number of fields.
if len(lines) < 2 or len(lines[0].split('\t')) != 18:
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
        # Field 15-18
        "TranscriptonURL" : "",
        "AssemblyListinURL" : "",
        "ColorizedURL" : "",
        "CoreDumpURL" : "",
        # Stuff that doesn't come from the database per se.
        "SizeFiles": [],
        "MonthFile": "",
        "DayFile": "",
        "YearFile": "",
        "PathFile": "",
        "EpochFile": 0,
        "Categorized": False
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
        record["Targets"] = simpleList(fields[6].lower())
        # For STS-nnn missions, I've often found documents that have relevance
        # for missions STS-nnn through STS-mmm, and it's quite a hassle to
        # manually list a bunch of missions like that.  I want instead to use
        # the shorthand STA-nnn-mmm.  So I catch that here:
        targets = record["Targets"]
        for i in range(len(targets)-1, -1, -1):
            target = targets[i]
            if target.startswith("sts-"):
                stsFields = target.split("-")
                if len(stsFields) == 3 and stsFields[1].isdigit() and \
                        stsFields[2].isdigit():
                    nnn = int(stsFields[1])
                    mmm = int(stsFields[2])
                    if nnn >= 1 and nnn < mmm and mmm <= 135:
                        t = []
                        for j in range(nnn, mmm+1):
                            t.append("sts-%d" % j)
                        targets[i:i] = t
    if len(fields) >= 8:    # Field 8
        record["Keywords"] = simpleList(fields[7].lower())
        if shuttle:
            for keyword in record["Keywords"]:
                if keyword in oi2sts:
                    for sts in oi2sts[keyword]:
                        if sts not in record["Targets"]:
                            record["Targets"].append(sts)
    if len(fields) >= 9:    # Field 9
        # The string replacement in the line below is a simple convenience for
        # me (RSB), so that I can cut-and-paste hyperlinks to local documents
        # and have the hyperlinks automatically turned into the correct web
        # hyperlinks without having to manually fix up each link myself.
        URLs = simpleList(re.sub("^.*/sandroid[.]org/public_html/", "https://www.ibiblio.org/", fields[8], 1))
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
                URLs[n] = URLs[n][lenRemote:]
                filePath = local + URLs[n]
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
        title = fields[9].strip()
        while title[-1:] == "." and title[-3:] != "...":
            title = title[:-1]
        record["Title"] = title
    if len(fields) >= 11:    # Field 11
        record["Archives"] = simpleList(fields[10].replace(", Jr", "%44 Jr"))
    if len(fields) >= 12:    # Field 12
        record["Sponsors"] = simpleList(fields[11].replace(", Jr", "%44 Jr"))
    if len(fields) >= 13:    # Field 13
        record["Disclaimer"] = fields[12].strip()
    if len(fields) >= 14:    # Field 14
        record["Comment"] = fields[13].strip()
    if len(fields) >= 15:    # Field 15
        record["TranscriptionURL"] = fields[14].strip().replace("http://www.ibiblio.org", "https://www.ibiblio.org")
    if len(fields) >= 16:    # Field 16
        record["AssemblyListingURL"] = fields[15].strip().replace("http://www.ibiblio.org", "https://www.ibiblio.org")
    if len(fields) >= 17:    # Field 17
        record["ColorizedURL"] = fields[16].strip().replace("http://www.ibiblio.org", "https://www.ibiblio.org")
    if len(fields) >= 18:    # Field 18
        record["CoreDumpURL"] = fields[17].strip().replace("http://www.ibiblio.org", "https://www.ibiblio.org")
        
    # Finish up this input line.
    records.append(record)

# Step 3:  Sanity Clause.  Look for duplicates.
allURLs = []
for record in records:
    allURLs += record["URLs"]
allURLs.sort()
for n in range(1, len(allURLs)):
    if allURLs[n-1] == allURLs[n]:
        print("Duplicate: " + allURLs[n], file=sys.stderr)

# Also, output a list of all the unique PDF links.  Remember that the
# URLs may have suffixes like "#page=..." that have to be removed, and
# character substitutions like " " -> "%20" that have to be undone.
# The general idea is to convert the URL to a filename that's in a form
# identical to what the 'find' command would come up with, because the 
# reason I'm even creating this file is to compare it to the list of PDFs
# already on the disk, to see what I've left out of the database.  To get
# the list of PDFs on the local drive, you do this:
#       cd To/the/local/apollo
#       find -type f -name "*.pdf" | LC_COLLATE=C sort -u >pdf.files
# Now you can diff or kompare (or whatever) pdf.files and buildLibraryPage.files.
for n in range(len(allURLs)):
    allURLs[n] = allURLs[n].split("#")[0].replace("%20", " ").replace("%44", ",").replace("%28", "(").replace("%29", ")")
allURLs.sort()
f = open("buildLibraryPage.files", "w")
if allURLs[0][-4:] == ".pdf":
    print(allURLs[0], file=f)
for n in range(1, len(allURLs)):
    if allURLs[n] != allURLs[n-1] and allURLs[n][-4:] == ".pdf":
        print("./" + allURLs[n], file=f)
f.close()

# Step 4:  Output the HTML file header.
currentEpoch = int(time.time())
cutoffEpoch = currentEpoch - cutoffMonths * 30 * 24 * 3600
if fancyHeaderAndFooter:
    print(fileHeader)
else:
    print("<!DOCTYPE html>")
    print("<html lang=\"en\">")
    print("<head>")
    print("<meta charset=\"utf-8\">")
    print("<title>Auto-Generated List of Recent Virtual AGC Document Library Additions</title>")
    print("</head>")
    print("<body>")

# Step 5:  Output the HTML body.

print(blurbTop)
print("<hr>")
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
    print("<hr>")
    print("<a name=\"Debug\"></a>")
    print("<h1>" + tableOfContentsSpec[0]["title"] + "</h1>")
    print(blurbDebug)
    print("<ol>")
    records.sort(key=tableOfContentsSpec[0]["sortKey"])
    for n in range(len(records)):
        if "blurb" in records["Keywords"]:
            continue
        html = documentEntryHTML(records[n], True)
        if html != "":
            print("<li>", end="")
            print(html, end="")    
            print("</li>")
    print("</ol>")

# Step 5A:  "Recent Additions" section.
if "anchor" in tableOfContentsSpec[1] and tableOfContentsSpec[1]["anchor"] == "RecentAdditions":
    everything = False
    print("<hr>")
    print("<a name=\"RecentAdditions\"></a>")
    print("<h1>" + tableOfContentsSpec[1]["title"] + "</h1>")
    print(blurbRecentlyAdded + "<br><br>")
    lastDateString = "00/00/0000"
    inUL = False
    reverse = False
    if "reverse" in tableOfContentsSpec[1] and tableOfContentsSpec[1]["reverse"]:
        reverse = True
    records.sort(reverse=reverse, key=tableOfContentsSpec[1]["sortKey"])  # Sort from newest (added) to oldest (added).
    for n in range(len(records)):
        record = records[n]
        epoch = myTimeSortKey(record)
        # Only show files for the last cutoffMonths, but if that's less than
        # cutoffFiles files, show some more.
        if epoch < cutoffEpoch and n >= cutoffFiles:
            break
        recordDateString = datetime.fromtimestamp(epoch).strftime("%m/%d/%Y")
        if recordDateString != lastDateString:
            if inUL:
                print("</ol>")
            print("<i>Added " + recordDateString + "</i>")
            inUL = True
            lastDateString = recordDateString
            if "blurb" in record["Keywords"]:
                print("<blockquote><b>Note:</b> " + record["Comment"] + "</blockquote><ol>")
                continue
            print("<ol>")
        print("<li>", end="")
        #print("\"" + myRecentSortKey(record) + "\"<br>")
        print(documentEntryHTML(record, False), end="")    
        print("</li>")
        records[n]["recent"] = True  # Used later for new.png.
    if inUL:
        print("</ol>")

# Step 5B:  Output all other sections, based on the parameters in 
# tableOfContentsSpec[].  
for n in range(2, len(tableOfContentsSpec)):
    numTotal = 0
    numUncategorized = 0
    everything = (n == len(tableOfContentsSpec) - 1)
    hrForYearChange = False
    if "hr" in tableOfContentsSpec[n]:
        hrForYearChange = True
        firstEntry = True
        lastYear = ""
    if "anchor" not in tableOfContentsSpec[n]:
        continue
    # Convert all keywords and targets being searched for to lower case.
    for key in [ "keywords", "targets" ]:
        if key in tableOfContentsSpec[n]:
            values = tableOfContentsSpec[n][key]
            for m in range(len(values)):
                values[m] = values[m].lower()
            tableOfContentsSpec[n][key] = values
    print("<hr>")
    print("<a name=\"" + tableOfContentsSpec[n]["anchor"] + "\"></a>")
    print("<h1>" + tableOfContentsSpec[n]["title"] + "</h1>")
    if "blurb" in tableOfContentsSpec[n]:
        print(tableOfContentsSpec[n]["blurb"])
    # Determine if we should add releaseTable.html to the end of the section
    # blurb.
    if "keywords" in tableOfContentsSpec[n]:
        if "release table" in tableOfContentsSpec[n]["keywords"]:
            f = open("releaseTable.html", "r")
            releaseTableLines = f.readlines();
            f.close()
            for line in releaseTableLines:
                print(line)
    if "none" in tableOfContentsSpec[n] and tableOfContentsSpec[n]["none"]:
        continue
    if "lineNumbers" in tableOfContentsSpec[n] and tableOfContentsSpec[n]["lineNumbers"]:
        print("<ol>")
    else:
        print("<ul>")
    if "sortKey" in tableOfContentsSpec[n]:
        records.sort(key=tableOfContentsSpec[n]["sortKey"])
    else:
        records.sort(key=myDateAuthorSortKey)
    keywordsSet = set([])
    targetsSet = set([])
    documentNumbers = []
    all = "all" in tableOfContentsSpec[n] and tableOfContentsSpec[n]["all"]
    if "keywords" in tableOfContentsSpec[n]:
        keywordsSet = set(tableOfContentsSpec[n]["keywords"])
    if "targets" in tableOfContentsSpec[n]:
        targetsSet = set(tableOfContentsSpec[n]["targets"])
    if "documentNumbers" in tableOfContentsSpec[n]:
        documentNumbers = tableOfContentsSpec[n]["documentNumbers"]
    for record in records:
        if "blurb" in record["Keywords"]:
            continue
        matched = False
        if all and record["Title"] != "" and len(record["URLs"]) > 0:
            matched = True
        elif len(list(keywordsSet & set(record["Keywords"]))) > 0:
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
            if not everything:
                record["Categorized"] = True
            else:
                numTotal += 1
                if not record["Categorized"]:
                    numUncategorized += 1
            print("<li>" + documentEntryHTML(record, True) + "</li>")
    if "lineNumbers" in tableOfContentsSpec[n] and tableOfContentsSpec[n]["lineNumbers"]:
        print("</ol>")
    else:
        print("</ul>")

print("%d of %d documents appear <i>only</i> in this section (%s), and perhaps might " \
      "therefore be categorized better than they are right now." \
      % (numUncategorized, numTotal, frowny))

# Final step: Cleanup.
if fancyHeaderAndFooter:
    print(fileFooter)
else:
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

