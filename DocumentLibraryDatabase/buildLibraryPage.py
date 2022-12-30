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
#
# Usage:
#	./buildLibraryPage.py <DocumentLibraryDatabase.tsv >../links2.html
# or
#	./buildLibraryPage.py --shuttle <ShuttleLibraryDatabase.tsv >../links-shuttle.html
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

shuttle = False
for param in sys.argv[1:]:
    if param == "--shuttle":
        shuttle = True

oldRemote = "http://www.ibiblio.org/apollo/"
remote = "https://www.ibiblio.org/apollo/"
local = "/home/rburkey/Desktop/sandroid.org/public_html/apollo/"
lenOldRemote = len(oldRemote)
lenRemote = len(remote)
lenLocal = len(local)

hoverColor = "#e0e0e0"
fancyHeaderAndFooter = True
#frowny = "&#128547;" # 😣
#frowny = "&#128533;" # 😕
frowny = "&#128558;" # 😮

title = "Apollo and Gemini"
if shuttle:
    title = "Space Shuttle"
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

currentEpoch = int(time.time())
currentDateString = time.strftime("%Y-%m-%d", time.localtime(currentEpoch))
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

# Here are various HTML blurbs that head up individual sections of the 
# document we're going to output.

blurbDebug = """
This section is present temporarily, only for the purpose of debugging.  It
will be removed before this auto-generated page goes live in production.
Right now, it simply lists every document in the library, in the same order
found on <a href="links.html">our 
previously-existing Document Library page</a> ... at least to the extent that
I've input the data.
"""

cutoffMonths = 2
if shuttle:
    blurbTop = """ 
    This is our library of Space Shuttle documents related in some way to the 
    onboard computer systems.  See also <a href="Shuttle.html">Space Shuttle
    page</a>.
    <br><br>
    To avoid clutter on your screens, some details we have &mdash; download 
    size, archive from which the digitization was made, name of the person who scanned
    the document or financially subsidized it, the organizational affiliations of
    the authors, the organizations which assigned the document numbers &mdash; are
    omitted from the entries for the documents.  You can get this kind of 
    information anyway, should you desire it, by hovering the mouse cursor over 
    the <span title="Download size, archive name, name of scanner/sponsor" 
    style="cursor:pointer; color:blue; text-decoration:underline">document title</span>, <code title="Organizational affiliation" 
    style="background-color:""" + hoverColor + """">author name</code>, or
    <code title="Organizational affiliation" style="background-color:
    """ + hoverColor + """
    ">document number</code>.  Notice the styling that's used to call your 
    attention to the availability of the extra information; authors' names or 
    document numbers without extra information available are not thusly highlighted.
    <br><br>
    Unless otherwise stated, documents are sorted by publication date, from 
    earliest to latest, and those with unknown dating appear at the top of the
    list.  Determination of the publication date is sometimes rather subjective.
    <br><br>
    Finally, this page is auto-generated from a database &mdash; actually a 
    spreadsheet &mdash; and if you desire, you can
    <a href="DocumentLibraryDatabase/ShuttleDocumentDatabase.tsv">
    download the spreadsheet</a>. (In pulling it into your spreadsheet program, 
    you mostly need to know that the columnar data is tab-delimited. There are
    additional rules that apply to fields containing comma-delimited lists or 
    organizational affiliations, but I won't bother to explain those things 
    further unless somebody actually asks me about them.)
    <br><br>
    """
    
    blurbRecentlyAdded = """
    This section lists all documents updated in the last 
    """ + "%d" % cutoffMonths + """
    months. 
    <br><br>
    The entries are arranged from most-recently added to least-recently added.
    """

    blurbXPL = """
    Unfortunately, as far as I can tell, the primary reference on XPL is the
    book <i>A Compiler Generator</i> by W. M. McKeeman, J. J. Horning, and 
    D. B. Wortman (1970).  Thus
    while there are various online resources you can find that try to 
    digest the information in that book and to spit the cud back at you one 
    way or another, there are few authoritative online documents I can point to.
    Less than one, actually.  I invite you to purchase the book &mdash; 
    which, naturally, is out of print but can be found used &mdash; or to
    google for resources online.
    """
    
    blurbFlowcharts = """
    Note that while a number of revisions of various volumes of the Space
    Shuttle Design Equations are available, I've been unable to locate 
    the presumably all-important Volume V - Flow Diagrams, 
    as well as Volume VI - Constants and Keyboard Accessible Parameters.
    """
    
    blurbEverything = """
    This section contains every document, in chronological order of publication,
    regardless of whether or not already appearing above.
    If an item appears only in this section, then perhaps we need to 
    categorize it better.  Such documents are marked with the emoji """ \
    + frowny + """.  Feel free to suggest better categorizations to us.
    """

else:
    blurbTop = """ 
    <i>(Our <a href="links.html">old version of this page</a> is still available, 
    but not likely to be updated in the future.)</i>
    <br><br>
    This is our Virtual AGC Document Library.  New submissions are 
    always welcome. Suggestions of where physical documents can be found for 
    subsequent digitization appear on our
    <a href="QuestForInfo.html">Documentation Quest page</a>.  
    Our <a href="faq.html#other_websites">FAQ page</a> points out various significant 
    Apollo-centric websites that may contain documents we've not so-far collected.
    <br><br>
    In the list below, some documents are provided by multiple links.  In general,
    when there's more than one link, the <i>first</i> one is to the one we feel
    most-inclined to recommend. The others may be lower resolution, larger 
    downloads, mutilated by the OCR process, missing some pages, or have some other 
    deficiencies that make them less preferable.  But the less-preferable documents
    are sometimes useful.
    <br><br>
    To avoid clutter on your screens, some details we have &mdash; download 
    size, archive from which the digitization was made, name of the person who scanned
    the document or financially subsidized it, the organizational affiliations of
    the authors, the organizations which assigned the document numbers &mdash; are
    omitted from the entries for the documents.  You can get this kind of 
    information anyway, should you desire it, by hovering the mouse cursor over 
    the <span title="Download size, archive name, name of scanner/sponsor" 
    style="cursor:pointer; color:blue; text-decoration:underline">document title</span>, <code title="Organizational affiliation" 
    style="background-color:""" + hoverColor + """">author name</code>, or
    <code title="Organizational affiliation" style="background-color:
    """ + hoverColor + """
    ">document number</code>.  Notice the styling that's used to call your 
    attention to the availability of the extra information; authors' names or 
    document numbers without extra information available are not thusly highlighted.
    <br><br>
    Unless otherwise stated, documents are sorted by publication date, from 
    earliest to latest, and those with unknown dating appear at the top of the
    list.  Determination of the publication date is sometimes rather subjective.
    <br><br>
    Finally, this page is auto-generated from a database &mdash; actually a 
    spreadsheet &mdash; and if you desire, you can
    <a href="DocumentLibraryDatabase/DocumentLibraryDatabase.tsv">
    download the spreadsheet</a>. (In pulling it into your spreadsheet program, 
    you mostly need to know that the columnar data is tab-delimited. There are
    additional rules that apply to fields containing comma-delimited lists or 
    organizational affiliations, but I won't bother to explain those things 
    further unless somebody actually asks me about them.)
    """

    blurbRecentlyAdded = """
    This section lists all documents updated in the last 
    """ + "%d" % cutoffMonths + """
    months. Note that recently-added <a href="#EngineeringDrawings">G&N 
    engineering drawings</a> are <i>not</i> included in the list.
    <br><br>
    The entries are arranged from most-recently added to least-recently added.
    <br><br>
    By the way, most documents listed in this section will also appear in one or
    more other sections of the library.  In those <i>other</i> sections, you find
    the new entries distinguished by the badge <img src="new.png">, but we don't 
    do that in this section, since obviously every document would have such
    a badge.
    """

    blurbPresentations = """
    Presentations from the MAPLD '04 conference, by AGC developers and other 
    knowledgeable folks.
    """

    blurbGSOPs = """
    The items below are arranged by MIT Instrumentation Laboratory document 
    number.
    """

    blurbPadloads = """
    Arranged by mission.
    """

    blurbAssemblyListing = """
    Here are listings of actual software for the various onboard guidance 
    computers covered by the Virtual AGC Project, as well as dumps of 
    physical computer-memory modules.  We don't have <i>all</i> of
    it, by any means, but we have what we have!  While all of the software 
    revisions listed below are equipped with comments
    &mdash; too many and too much, some may say &mdash; there tend to be much
    longer writeups on the pages specifically devoted to them.  So if you want
    even more detail, I'd suggest looking in one of these places: the 
    <a href="yaAGS.html">AGS page</a>, the <a href="LVDC.html">LVDC/PTC page</a>,
    the <a href="Luminary.html">LM AGC software page</a>, or the
    <a href="Colossus.html">CM AGC software page</a>
    <br><br>
    The collection contains many software revisions which never flew in Apollo 
    missions, and conversely there are missions for which we don't have some of 
    the software.  And, there are missions for which we may not have the <i>exact</i>
    software revision originally used, but do have a revision which is fine for
    successfully flying a simulated mission.  Here's a mission-by-mission
    summary of what we presently have and don't have:<br><br>
    <table cellspacing="2" cellpadding="2" border="1" align="center" style="font-family:sans-serif"><tbody>
    <tr style="font-weight:bold" align="center"><td>Mission</td><td>CM AGC</td><td>LM AGC</td><td>AGS</td><td>LVDC</td></tr>
    <tr align="center"><td>AS-202</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 1</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 4</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 5</td><td>n/a</td><td>yes</td><td>no</td><td>no</td></tr>
    <tr align="center"><td>Apollo 6</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 7</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 8</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Apollo 9</td><td>yes</td><td>fine</td><td>no</td><td>no</td></tr>
    <tr align="center"><td>Apollo 10</td><td>yes</td><td>yes</td><td>no</td><td>no</td></tr>
    <tr align="center"><td>Apollo 11</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
    <tr align="center"><td>Apollo 12</td><td>no</td><td>yes</td><td>yes</td><td>no</td></tr>
    <tr align="center"><td>Apollo 13</td><td>no</td><td>yes</td><td>no</td><td>no</td></tr>
    <tr align="center"><td>Apollo 14</td><td>no</td><td>yes</td><td>no</td><td>no</td></tr>
    <tr align="center"><td>Apollo 15</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
    <tr align="center"><td>Apollo 16</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
    <tr align="center"><td>Apollo 17</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
    <tr align="center"><td>Skylab 2</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Skylab 3</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>Skylab 4</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    <tr align="center"><td>ASTP</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
    </tbody></table><br>
    <a href="DocumentLibraryDatabase/AGCSoftwareTree.svg">
    <img src="detailAGCSoftwareTree.png" alt="" style="float:right; border:2px solid blue">
    </a>If just seeing 
    what went into each mission isn't enough for you, and you need to see the vast 
    sweep of all the AGC and AGS software development from the beginning in 1963 
    until the end in 1971, I have a chart of that as well. Alas, there's no LVDC 
    info in the chart, and I've had to leave out some AGC non-mission branches like LA MESH,
    DIANA, and so forth. But I included some non-mission branches,
    particularly SHEPATIN and ZERLINA, since we actually have representative
    copies of those. There's a small detail 
    from the full chart to the right, and if you click that image, the full chart 
    will appear. Admittedly, there's some guesswork involved because of lacking 
    information, particularly in the very early years, but I think the chart 
    captures pretty well what's going on.  Each bubble in the chart represents
    some specific revision of some specific AGC program, or else a range of 
    revisions when there's just too much information missing to distinguish 
    between them.  Gray bubbles are Block 1 code, brown bubbles are Block 2 CM
    code, yellow bubbles are LM code, and white bubble are AGS. The name of the 
    AGC program is in red if
    core ropes were actually manufactured for that revision.  The arrows connecting
    the bubbles tell you what revisions of what programs evolved into what other
    revisions.  The arrows are also decorated with lists telling what PCRs, PCNs,
    software-anomaly reports, and ACB requests were involved in that particular
    stage of the evolution &mdash; though in many cases that's simply "TBD", as it
    actually is in the detail image at the right. The
    full chart, by the way, is about 40 times as high as it is wide, so be 
    prepared to scroll downward a <i>lot</i> if you look at very much of it.<br>
    <br>
    The table below is a list of all releases of AGC software (that we're aware of)
    for the purpose of manufacturing core-rope memory modules.  This information
    was gleaned from many, many documents in the library, as opposed to a single
    authoritative source, so there are unfortunately many gaps and question marks
    in the table.  A number of the software revisions for which we have the source
    code were never manufactured into memory modules, such as ZERLINA, SUPER JOB,
    and DAP AURORA, so they don't appear in the table at all.  Conversely, there
    are many software revisions manufactured as ropes for which we have no 
    contemporary source listing or modern reconstruction.<br><br>
    """

    blurbMathFlow = """
    The term "math flow" refers to the underlying, implementation-independent,
    mathematical algorithms that are &mdash; at some point in the development
    process &mdash; coded as guidance-computer instructions.  Or another way of 
    looking at it, I suppose, is that the math flow encompasses the algorithms
    needed to <i>program</i> the guidance computers, as opposed to the information need
    to <i>use</i> those computers after they're programmed.
    <br><br>
    There are several ways the Apollo and Gemini guidance computers' math flow 
    are represented in our collected documentation.
    For example, there may simply be a set of mathematical equations that represent
    the physics of spacecraft motion.  At the other end of the spectrum, there 
    may be detailed sets of flowcharts that form an almost-complete pictorial 
    representation of the
    eventual computer program's control flow and handling of variables.  The
    entire continuum of possibilities is represented in this section, for all of 
    the types of guidance computers covered by the Virtual AGC Project.
    """

    blurbSGA = """
    If you are interested in the mathematical underpinnings of the AGC software, 
    then this amazing series of memos from MIT's Instrumentation Lab is the place 
    to look.  It is very interesting
    to reflect on the fact that these mathematical memos are often written by the 
    very same people whose names you find as authors in the software.  The AGC 
    software was written in a time ... or at least a place ... where software was 
    regarded as the expression of mathematical knowledge as opposed to being a mere 
    exercise in the expert employment of programming languages and tools as it is 
    today.  It is interesting also to reflect on the nature of the software this 
    approach produced.
    """

    blurbDD = """
    These memos primarily relate to the electrical design of the AGC.
    """

    blurbXDE = """
    These are notes from AC Spark Plug Division, commenting on topics peripheral 
    to the AGC, such as ground-support equipment.
    """

    blurbLuminaryMemos = """
    The "LUMINARY Memos" are internal memos from the MIT Instrumentation Laboratory 
    dealing with issues of LUMINARY software development, along with 
    closely-related software branches such as ZERLINA.
    <br><br>
    Of particular interest, 
    if you're concerned with the evolution of the AGC software, are the many memos 
    used to document the changes of the LUMINARY code from one revision to the 
    next.  In theory, if you had all of them, you could come pretty close to using
    them to document the complete evolution of LUMINARY, or at any rate from 
    LUMINARY 4 (memo #22) through LUMINARY 209 (memo #205).
    <br><br>
    But back to the memos. Over 250 of them are known, of which we've gotten the 
    majority from Don Eyles's personal collection. The items which are grayed-out 
    relate to memos about which we have some information but not the actual memos 
    themselves. 
    <br><br>
    The items are arranged according to their memo numbers.
    """

    blurbPcrsPcns = """
    Program Change Requests (PCRs) were the official mechanism by which proposed
    AGC software changes were submitted to the NASA's Software 
    Control Board (SCB), for subsequent approval or rejection.  The PCR was the 
    normal tool for this, and PCRs could be created either by MIT/IL or by NASA,
    but did not take effect until action was taken by the SCB.  The lesser-used
    PCN is almost the same as a PCR, except that MIT/IL unilaterally put them into
    effect <i>as if</i> NASA's SCB had approved them ... even though the SCB 
    <i>could</i> end up disapproving the PCN and forcing MIT/IL to undo whatever
    work they had done in connection with it. Often the PCN was used for simple
    clerical changes in the GSOP, which were almost certain to eventually win SCB
    approval, but sometimes they were apparently used for issues that blocked 
    further development and thus which would cause scheduling issues if it were 
    necessary to stop work until the next SCB meeting.  In any case, the 
    signficance (for us) of either PCRs or PCNs is 
    that since AGC software changes were
    governed by them, knowledge of the PCRs/PCNs is of tremendous importance in 
    tracking changes between AGC software revisions ... or 
    alternatively, of no importance whatever if you're not interested in 
    understanding the evolution of the software.
    <br><br>
    When the full text of a PCR or PCN isn't currently available, information 
    has instead come from
    other contemporary documentation, including:
    <ul>
    <li>Lists in the GSOP documents of PCRs/PCNs incorporated into various AGC revisions.</li>
    <li>SCB meeting minutes listing PCRs/PCNs which had been approved or rejected.
    The SCB minutes often give a much fuller explanation than the mere titles of
    the PCRs/PCNs provide.</li>
    <li>LUMINARY or COLOSSUS memos describing the revision-to-revision changes in
    the software.  These also may give more information than the mere titles of the
    PCRs or PCNs.</li>
    <li>Lists of PCRs/PCNs compiled by the development managers for various missions.</li>
    </ul>
    None of these sources are meticulous about using the exact titles of the PCRs.
    <br><br>
    All known PCRs and PCNs for which we have any information at all are listed,
    whether approved or disapproved by the SCB, and whether or not a copy is currently 
    available in the library.  Unless stated otherwise, PCRs/PCNs were approved for
    implementation.  The entries below are arranged by PCR/PCN number. We've also 
    added a rough categorization to 
    each PCR/PCN entry as to which AGC program(s) it applies to:  SUNDISK, SUNDANCE, 
    LUMINARY, COLOSSUS (which includes COMANCHE and ARTEMIS), or SKYLARK.
    """

    blurbAnomalies = """
    In this section, we cover Assembly Control Board Requests and
    Software Anomaly Reports.  These acted similarly to PCRs and 
    PCNs (see above), and have a similar importance for us in 
    understanding the evolution of AGC software over time.  The difference from 
    PCRs/PCNs is that approvals or rejections were made by MIT/IL's
    Assembly Control Board (ACB) rather than by NASA's SCB.  The scopes of the 
    SCB's actions and the ACB's actions differed in that the SCB decided upon the 
    contents of (or changes to) the software specification (which
    was regarded as the GSOP document), whereas the ACB examined discrepancies 
    between the software and the specification, or else items left unspecified 
    altogether by the GSOP (and therefore presumably of little or no importance
    to the SCB).  Thus being entirely internal to MIT/IL, ACB Requests and 
    Software Anomaly Reports could presumably
    be acted upon much more quickly and easily than was the case for PCRs and PCNs.
    <br><br>
    ACB Requests and Software Anomaly Reports have no titles as such, so the titles 
    given below are actually extracts from the (often rather long) problem 
    descriptions given in forms.  The entries are sorted by document number.
    """

    blurbAGS = """
    """

    blurbLVDC = """
    We have precious little LVDC documentation, and even less LVDC software.  
    The Wikipedia article on the LVDC at the time I first wrote on this subject
    lamented that all of the LVDC software has probably vanished and does not exist 
    any longer. Fortunately, that has turned out to be false, although there may
    be enough truth in it to make us very uncomfortable.
    """

    blurbIMCC = """
    This section relates to the Integrated Mission Control Center (IMCC), and
    to its facilities, particularly the Mission Control Center in 
    Houston (MCC-Houston) and the Real Time Computer Complex (RTCC).  Emphasis is
    on the physical facilities and their development and history, rather than 
    anything they accomplished in so far as specific Gemini or Apollo missions 
    are concerned.
    """

    blurbSoundAndFury = """
    The title of this section is a little misleading, in that many people, upon 
    seeing the lead-in "sound and fury ...", would immediately fill in the ending 
    "... signifying nothing". 
    <br><br>
    I certainly don't intend to imply that the items in this section "signify 
    nothing", but you may nevertheless have to put in a little more effort to 
    determine just what they do signify within the context of AGC development.  
    That's because these memos share some common characteristics that add to your 
    confusion, such as:
    <br>
    <ul>
      <li>They present just one side of an obviously two-sided
        discussion.</li>
      <li>They don't tend to share the emotionally-neutral tone that
        almost every other document in this library has.<br>
      </li>
      <li>We don't know the personal interrelationships between the
        people involved.</li>
      <li>They were written before the invention of emojis. 
      <img src="smiley.png" alt="" width="16" height="16"></li>
    </ul>
    And there may be individually-complicating features as well.  One of the memos, 
    for example, was written on April Fools' Day.  Is it fooling, or is it not?  I 
    can't say.  What I can say is that if you decode the memos properly, it's 
    possible that there may be lessons to be learned from them.
    """

    blurbSomethingDifferent = """
    In this section, we provide some stuff that doesn't directly pertain to any of 
    the computers in Apollo or Gemini.  But if the original developers give me 
    interesting and sometimes unique material, or if I find interesting material 
    related to them, I'd like to present it anyway. 
    """

    blurbElectroMechanical = """
    Electrical and mechanical engineering drawings of Apollo systems cannot be 
    represented well in this Document Library page, because there are hundreds of 
    thousands of them.
    <br><br>
    Large numbers of engineering drawings are presented here <i>indirectly</i>, in
    two ways.  The first way is
    in the form of "drawing trees".  For example, Apollo 11 contained 2 Guidance
    & Navigation
    systems, one for the CM (drawing 2014999-101) and one for the LM 
    (drawing 6014999-091). Each of these, in turn, represents a set of drawings, 
    with one drawing for each
    of its assemblies.  And each of those assembly drawings represents yet another 
    set of 
    drawings, one for each of its subassemblies.  And so on.  But only the
    two top-level drawings for any given mission are explicitly presented here.  
    It is those top-level drawings that serve as a portal to allow you to 
    navigate throughout the entire hierarchy of drawings. The second way engineering
    drawings are represented indirectly is in the
    guise of NARA-SW (National Archives, Ft. Worth) aperture-card boxes, each of
    which holds ~1800 microform images of drawings.  This aperture-card box 
    form is useful for seeing
    entire groups of engineering drawings that have been newly added to the 
    Document Library as new aperture-card boxes are scanned.
    <br><br>
    You also have the option of instead going to our 
    <a href="TipueSearch.html">G&N engineering-drawing search engine</a>
     which allows you to find engineering drawings by fragments of drawing numbers 
    or drawing titles.  Or you can try our <a href="ElectroMechanical.html">
    Electro-Mechanical page</a>, which may provide additional resources or 
    related information.
    """

    blurbEverything = """
    If none of the sections above coincides with your special interests, this 
    section may help.  It contains <i>every</i> item in our Document Library, 
    whether or not those documents were already included in the preceding sections.
    (Excluding, of course, some G&N system engineering drawings, as explained
    in the immediately-preceding section.)  The entries are ordered by 
    publication date.
    <br><br>
    If an item appears <i>only</i> in this section, then perhaps it should be
    categorized better!  If so, you'll find it marked with the emoji """ \
    + frowny + """. Feedback about additional sections for the library or
    membership of individual documents in specific library sections is welcome.
    <br><br>
    If you <i>still</i> can't find what you need after you've looked in this 
    section, you might consider using the Google searchbar that appears near the 
    top of this page. It has the great advantage of searching not only document 
    titles, document numbers, and authors, but in fact does a complete search of 
    the text <i>within</i> the documents ... and not only here on this Document 
    Library page, but for all pages on the Virtual AGC website.  Alas, the optical
    character recognition (OCR) process that creates the text index is not perfect,
    so your search may still fail even if the document you want is present.  But
    then, what <i>is</i> perfect in this old world?
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

def myPubDateSortKey(record):
    month = record["MonthPublished"]
    day = record["DayPublished"]
    year = record["YearPublished"]
    if year == "":
        year = "0000"
    if month == "":
        month = "00"
    if day == "":
        day = "00"
    return year + month + day

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

# Used for sorting the records in order of descending newness.
def myTimeSortKey(record):
    epoch = record["EpochAdded"]
    if record["EpochFile"] > epoch:
        epoch = record["EpochFile"]
    return epoch

# This sorting key not only reverses the order of myTimeSortKey, but 
# also reduces it to an integral number of days, without hours, minutes, 
# seconds.
def myTimeReverseSortKey(record):
    if False:
        days = myTimeSortKey(record) // 86400
        reverse = 99999 - days 
        return "%05d" % reverse
    else:
        epoch = myTimeSortKey(record)
        epochString = datetime.fromtimestamp(epoch).strftime("%Y/%m/%d")
        fields = epochString.split("/")
        reverseEpoch = "%04d%02d%02d" % ( 9999-int(fields[0]), 99-int(fields[1]), 99-int(fields[2]))
        return reverseEpoch

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

# Tries to normalize the form of document numbers of the form 
# x-y-...-z[.u] by turning all fields that are pure integers into 
# zero-padded fixed lengths. If there are multiple document numbers,
# only the primary one is used.
def myDashSortKey(record):
    if len(record["DocumentNumbers"]) == 0:
        return ""
    fields = re.split('[-.]' , record["DocumentNumbers"][0]["Number"])
    key = ""
    for field in fields:
        if field == "PCN":
            field = "PCR"
        key += "%10s" % field
    return key

# Sort key for database order.
def myOriginalSortKey(record):
    return record["lineNumber"]

# Sort key for document titles.
def myTitleSortKey(record):
    return record["Title"]

# Sort key for authors.  This is really tricky. This is really tricky.  We
# have to be able to normalize names from FIRST [MIDDLE] LAST [SUFFIX] to
# LAST FIRST [MIDDLE] [SUFFIX].  But we also have to distinguish that case
# from the case of corporate authors like "MIT Instrumentation Lab" (which
# we don't want converted to "Lab MIT Instrumentation").  Then too, there
# may be multiple authors, so we need to normalize each author name into
# a fixed-length string (of adequate length) and concatenate them all.  
# Finally, if the names match, we need to add on the title as a secondary
# sort field.
def myAuthorSortKey(record):
    output = ""
    for author in record["Authors"]:
        authorName = author["Name"].upper()
        if author["Organization"] != "":
            # If we've gotten here, then the authorName is an individual
            # rather than a corporate author (if the author names are
            # formatted properly in the database).  We have to normalize
            # by picking off the author's last name, and putting it 
            # first.
            nameFields = authorName.split()
            if len(nameFields) > 0:
                if nameFields[-1] in [ "JR", "JR.", "SR", "SR.", "III", "IV", "V", "VI", "VII", "VIII" ]:
                    suffix = nameFields[-1]
                    nameFields = nameFields[:-1]
                else:
                    suffix = ""
                if len(nameFields) > 0:
                    lastName = nameFields[-1]
                    nameFields = nameFields[:-1]
                    while lastName[-1:] == ",":
                        lastName = lastName[:-1]
                    authorName = lastName
                    for n in nameFields:
                        authorName += " " + n
                    if suffix != "":
                        authorName += " " + suffix
        output += "%-30s" % authorName
    return output + record["Title"].upper()

def myDateAuthorSortKey(record):
    key = myPubDateSortKey(record) + myAuthorSortKey(record)
    # print ("\"%s\" %s" % (key, record["Title"]), file=sys.stderr)
    return key

def myMissionSortKey(record):
    targets = record["Targets"]
    if len(targets) > 0:
        fmt = "%-10s%10s"
        firstTarget = targets[0].lower()
        if "as-" == firstTarget[:3]:
            key = fmt % ("1as-", firstTarget[3:].strip())
        elif "apollo " == firstTarget[:7]:
            key = fmt % ("2apollo", firstTarget[7:].strip())
        elif "skylab" == firstTarget:
            key = fmt % ("3skylab", "1")
        elif "skylab " == firstTarget[:7]:
            key = fmt % ("3skylab", firstTarget[7:].strip())
        elif "astp" == firstTarget[:4]:
            key = fmt % ("4astp", "")
        else:
            key = fmt % ("", "")
        #print("'" + key + "'", file=sys.stderr)
        return key
    return ""

# Sort key used for the "Recently Added" section.  We want to sort primarily
# on the epoch added (myTimeSortKey), but then secondarily the way we
# normally sort on publication date and author (myDateAuthorSortKey).  The
# problem is that the former we want in descending order but that we want
# the latter in ascending order.  To account for that, we mathematically
# manipulate the epoch to reverse the sort order for just that field.
def myRecentSortKey(record):
    key = myTimeReverseSortKey(record)
    if "blurb" in record["Keywords"]:
        key = key + "A"
    else:
        key = key + "B"
    key += myDateAuthorSortKey(record)
    return key

# For sorting software anomalies.
def myAnomalySortKey(record):
    if len(record["DocumentNumbers"]) == 0:
        return ""
    key = record["DocumentNumbers"][0]["Number"]
    fields = key.split("-")
    while len(fields[0]) < 3:
        fields[0] += "Z"
    if len(fields) == 2:
        while len(fields[1]) < 3:
            fields[1] = "0" + fields[1]
        key = fields[0] + fields[1]
    elif len(fields) == 3:
        while len(fields[2]) < 3:
            fields[2] = "0" + fields[2]
        key = fields[0] + fields[1] + fields[2]
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
        hover += "Scanned by: " + Sponsors[n] + ". "
    if len(Archives) > n and Archives[n] != "":
        archive = Archives[n]
        if archive in archiveAbbreviations:
            archive = archiveAbbreviations[archive]
        hover += "Archived by: " + archive + "."
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
    "GE" : "General Electric"
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
        portion = portion[:1].lower() + portion[1:]
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

# The following list determines how to divide the page up into sections.
# Items are chosen for the sections based on the parameters in the table,
# and on document-specific data in the database, such as document numbers,
# targets, and keywords. The parameters targets[] and keywords[] are simply
# lists of targets and keywords that may appear in the database, and an item
# is included in the section if there is any overlap. The DocumentNumbers[]
# parameters, on the other hand, try to match only the leading portions of
# strings.  As an alternative to the above, you can include the key/value
# pair "all":True (which matches *all* records) or "none":True (which matches
# *no* record, but still creates a section with a blurb).
#
# Note that the default collating function is myDateAuthorSortKey, so if that's
# what's wanted, you can simply leave out 
#       "sortKey" : myDateAuthorSortKey
#
# The anchor field must have a matching <a name="..."></a> tag.
# Only entries with an "anchor" key are used in the table of contents.
# Never remove the 1st two entries below, but the "anchor" can be removed
# to disable either of the first 2 entries.  If restored, the anchors must
# be "Debug" and "RecentAdditions" precisely.  Note that keyword- and
# target-searches are not case sensitive; in practice, they will all be 
# converted to lower-case, regardless of how they're entered in this array.
#
# The keyword "release table" is special.  It is used only in the list below,
# and not in the database.  When present, the file releaseTable.html is fetched
# and inserted as-is below the section's blurb.  I expect this is useful only
# for the Assembly Listings section, though a similar technique might be useful
# someday in other sections.  If used, the file releaseTable.html
# should be prepared from the Google Sheets spreadsheet titled
# "Known AGC Software Releases" by using the instructions in the script
# fixReleaseTable.py.
if shuttle:
    tableOfContentsSpec = [
        { "title" : "Debug", "sortKey" : myOriginalSortKey, "blurb" : blurbDebug },
        { "anchor" : "RecentAdditions", "title" : "Recently Added Documents as of %s" % currentDateString, "sortKey" : myRecentSortKey, "blurb" : blurbRecentlyAdded },
        { "anchor" : "flowcharts", "title" : "Design Equations and Flowcharts", "keywords" : [ "flowcharts", "flowchart", "design equations" ], "blurb" : blurbFlowcharts },
        { "anchor" : "Avionics", "title" : "Avionics", "keywords" : [ "avionics" ] },
        { "anchor" : "HAL/S", "title" : "HAL/S Language", "keywords" : [ "HAL/S" ] },
        { "anchor" : "XPL", "title" : "XPL Language", "keywords" : ["XPL" ], "blurb" : blurbXPL },
        { "anchor" : "PASS", "title" : "Primary Avionics Software System (PASS)", "keywords" : [ "PASS" ] },
        { "anchor" : "PFS", "title" : "Primary Flight Software (PFS)", "keywords" : [ "PFS" ] },
        { "anchor" : "BFS", "title" : "Backup Flight System (BFS)", "keywords" : [ "BFS" ] },
        { "anchor" : "RTL", "title" : "Run-Time Library (RTL)", "keywords" : [ "RTL" ] },
        { "anchor" : "FCOS", "title" : "Flight Control Operating System (FCOS)", "keywords" : [ "FCOS" ] },
        { "anchor" : "DPS", "title" : "Data Processing Subsystem (DPS)", "keywords" : [ "DPS" ] },
        { "anchor" : "GPC", "title" : "General Purpose Computer (GPC), IBM AP-101S Avionics Computer", "keywords" : [ "AP-101S", "GPC" ] },
        { "anchor" : "FCS", "title" : "Flight Control System (FCS)", "keywords" : [ "FCS" ] },
        { "anchor" : "OI2", "title" : "Software Version OI-2", "keywords" : [ "OI-2" ] },
        { "anchor" : "OI4", "title" : "Software Version OI-4", "keywords" : [ "OI-4" ] },
        { "anchor" : "OI5", "title" : "Software Version OI-5", "keywords" : [ "OI-5" ] },
        { "anchor" : "OI6", "title" : "Software Version OI-6", "keywords" : [ "OI-6" ] },
        { "anchor" : "OI7", "title" : "Software Version OI-7", "keywords" : [ "OI-7" ] },
        { "anchor" : "OI8", "title" : "Software Version OI-8", "keywords" : [ "OI-8", "OI-8B", "OI-8C", "OI-8D", "OI-8F" ] },
        { "anchor" : "OI20", "title" : "Software Version OI-20", "keywords" : [ "OI-20" ] },
        { "anchor" : "OI21", "title" : "Software Version OI-21", "keywords" : [ "OI-21" ] },
        { "anchor" : "OI22", "title" : "Software Version OI-22", "keywords" : [ "OI-22" ] },
        { "anchor" : "OI23", "title" : "Software Version OI-23", "keywords" : [ "OI-23" ] },
        { "anchor" : "OI24", "title" : "Software Version OI-24", "keywords" : [ "OI-24" ] },
        { "anchor" : "OI25", "title" : "Software Version OI-25", "keywords" : [ "OI-25" ] },
        { "anchor" : "OI26", "title" : "Software Version OI-26", "keywords" : [ "OI-26", "OI-26A", "OI-26B" ] },
        { "anchor" : "OI27", "title" : "Software Version OI-27", "keywords" : [ "OI-27" ] },
        { "anchor" : "OI28", "title" : "Software Version OI-28", "keywords" : [ "OI-28" ] },
        { "anchor" : "OI29", "title" : "Software Version OI-29", "keywords" : [ "OI-29" ] },
        { "anchor" : "OI30", "title" : "Software Version OI-30", "keywords" : [ "OI-30" ] },
        { "anchor" : "OI32", "title" : "Software Version OI-32", "keywords" : [ "OI-32" ] },
        { "anchor" : "OI33", "title" : "Software Version OI-33", "keywords" : [ "OI-33" ] },
        { "anchor" : "OI34", "title" : "Software Version OI-34", "keywords" : [ "OI-34" ] },
        { "anchor" : "GOAL", "title" : "Ground Operations Aerospace Language (GOAL)", "keywords" : [ "GOAL" ] },
        { "anchor" : "papers", "title" : "Papers, Articles, Presentations, Books", "keywords" : [ "papers", "paper" ] },
        { "anchor" : "studies", "title" : "Studies, Analyses", "keywords" : [ "studies" ] },
        { "anchor" : "requirements", "title" : "Requirements", "keywords" : [ "requirements" ] },
        { "anchor" : "DevTools", "title" : "Development Tools", "keywords" : [ "dev tools" ] },
        { "anchor" : "FlightData", "title" : "Flight Data Files, Checklists, Handbooks, Procedures", "keywords" : [ "flight data" ] },
        { "anchor" : "Training", "title" : "STS Training", "keywords" : [ "crew training", "training" ] },
        { "anchor" : "FlightProcedures", "title" : "STS Flight Procedures", "keywords" : ["flight procedures" ] },
        { "anchor" : "Support", "title" : "Support Documents" , "keywords" : ["support", "support documents"] },
        { "anchor" : "Aerodynamics", "title" : "Aerodynamics", "keywords" : ["aerodynamics"] },
        { "anchor" : "Structural", "title" : "Structural Design", "keywords" : ["structural"] },
        { "anchor" : "LifeSupport", "title" : "Life Support, Environmental, Crew Station", "keywords" : ["life support"] },
        { "anchor" : "Ground", "title" : "Ground Operations", "keywords" : ["ground"] },
        { "anchor" : "Administrative", "title" : "Administrative", "keywords" : ["administrative"] },
        { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True, "lineNumbers" : True, "hr" : True }
    ]
else:
    tableOfContentsSpec = [
        { "title" : "Debug", "sortKey" : myOriginalSortKey, "blurb" : blurbDebug },
        { "anchor" : "RecentAdditions", "title" : "Recently Added Documents as of %s" % currentDateString, "sortKey" : myRecentSortKey, "blurb" : blurbRecentlyAdded },
        { "anchor" : "Presentations", "title" : "Presentations", "sortKey" : myAuthorSortKey, "keywords" : ["Presentation"], "blurb" : blurbPresentations },
        { "anchor" : "ProgrammerManuals", "title" : "Programmers' Manuals", "keywords" : ["Programmer manual"]},
        { "anchor" : "UserGuides", "title" : "Onboard Computer Users' Guides", "keywords" : [ "AGC user guide", "AGS user guide", "OBC user guide" ] },
        { "anchor" : "GSOPs", "title" : "Guidance System Operations Plans (GSOP)", "sortKey" : myDashSortKey, "keywords" : [ "GSOP" ], "blurb" : blurbGSOPs },
        { "anchor" : "ReferenceCards", "title" : "Quick-Reference Cards, Data Cards, Cue Cards", "keywords" : ["Reference cards"]},
        { "anchor" : "PadLoads", "title" : "AGC Pad Loads", "sortKey" : myMissionSortKey, "keywords" : [ "Pad load" ], "blurb" : blurbPadloads },
        { "anchor" : "EMPs", "title" : "Erasable Memory Programs (EMP)", "keywords" : ["Erasable memory programs", "EMP"]},
        { "anchor" : "AssemblyListings", "title" : "Software Listings and Dumps", "keywords" : ["Assembly listing", "release table", "module dump"], "blurb" : blurbAssemblyListing },
        { "anchor" : "MathFlow", "title" : "Math Flow", "keywords" : [ "Guidance equations" ], "blurb" : blurbMathFlow },
        { "anchor" : "SGAMemos", "title" : "Space Guidance Analysis Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Space Guidance Analysis Memo"], "blurb" : blurbSGA },
        { "anchor" : "ApolloProjectMemos", "title" : "Apollo Project Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Apollo Project Memo"] },
        { "anchor" : "ApolloEngineeringMemos", "title" : "Apollo Engineering Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Apollo Engineering Memo"] },
        { "anchor" : "DigitalDevelopmentMemos", "title" : "Digital Development Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Digital Development Memo"], "blurb" : blurbDD },
        { "anchor" : "ElectronicDesignGroupMemos", "title" : "Electronic Design Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Electronic Design Group Memo"] },
        { "anchor" : "ISSMemos", "title" : "Inertial Sub-System (I.S.S.) Memos", "sortKey" : myDocSortKeyReverse, "documentNumbers" : ["ISS Memo"] },
        { "anchor" : "XDENotes", "title" : "XDE Notes", "sortKey" : myXdeSortKey, "documentNumbers" : ["XDE-"], "blurb" : blurbXDE },
        { "anchor" : "DigitalGroupMemos", "title" : "Digital Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["DG Memo"] },
        { "anchor" : "MissionTechniquesMemos", "title" : "Mission Techniques Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Mission Techniques Memo"] },
        { "anchor" : "SystemTestGroupMemos", "title" : "System Test Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["System Test Group Memo"] },
        { "anchor" : "Requirements", "title" : "AGC/AGS Software Requirements", "keywords" : ["Software requirements"]},
        { "anchor" : "LuminaryMemos", "title" : "LUMINARY Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["LUMINARY Memo"], "blurb" : blurbLuminaryMemos },
        { "anchor" : "ColossusMemos", "title" : "COLOSSUS Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["COLOSSUS Memo"] },
        { "anchor" : "SkylarkMemos", "title" : "SKYLARK (SKYLAB) Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["SKYLARK Memo", "SKYLAB Memo"] },
        { "anchor" : "PcrsPcns", "title" : "Program Change Requests (PCR) and Notices (PCN)", "sortKey" : myDashSortKey, 
                        "documentNumbers" : [ "PCR-", "PCN-"], "blurb" : blurbPcrsPcns  },
        { "anchor" : "Anomalies", "title" : "Software Anomaly Reports and Assembly Control Board Requests", "sortKey" : myAnomalySortKey, 
                        "blurb" : blurbAnomalies, "documentNumbers" : [ "ACB-", "LNY-", "L-", "COL-", "COM-", "A-" ] },
        { "anchor" : "SCB", "title" : "Software Control Board (SCB)", "keywords" : ["SCB"]},
        { "anchor" : "SDP", "title" : "Software Development Plans", "keywords" : ["SDP"]},
        { "anchor" : "Block1", "title" : "Block I Specifics", "keywords" : ["Block 1"]},
        { "anchor" : "AGS", "title" : "Abort Guidance System (AGS)", "blurb" : blurbAGS, "keywords" : [ "AGS" ] },
        { "anchor" : "LVDC", "title" : "Launch Vehicle Digital Computer (LVDC) and Friends", "blurb" : blurbLVDC, "keywords" : [ "LVDC", "LVDA", "FCC", "IU" ] },
        { "anchor" : "Experience", "title" : "Apollo Experience Reports", "keywords" : ["Experience report"]},
        { "anchor" : "StudyGuides", "title" : "Training and Study Guides", "keywords" : ["Training", "Study Guide"]},
        { "anchor" : "SystemsHandbooks", "title" : "Systems Handbooks", "keywords" : ["systems handbook"]},
        { "anchor" : "OperationsHandbooks", "title" : "Operations Handbooks", "keywords" : ["operations handbook"]},
        { "anchor" : "OperationalDataBooks", "title" : "Operational Data Books", "keywords" : ["operational data book"]},
        { "anchor" : "CrewDebriefing", "title" : "Technical Crew Debriefings", "keywords" : ["Debriefing"]},
        { "anchor" : "Postflight", "title" : "Mission Reports and Trajectory Reconstructions", "keywords" : ["Mission report", "Trajectory reconstruction"]},
        { "anchor" : "FlightPlan", "title" : "Flight Plans and Planned Trajectories", "keywords" : ["flight plan", "trajectory"]},
        { "anchor" : "FlightData", "title" : "Flight Data Files (Checklists, G&N Dictionaries, ...)", "keywords" : ["flight data"]},
        { "anchor" : "SpacecraftFamiliarization", "title" : "Spacecraft Familiarization Manuals", "keywords" : ["spacecraft familiarization"]},
        { "anchor" : "FlightEvaluation", "title" : "Launch Vehicle and Spacecraft Flight Evaluation Reports", "keywords" : ["flight evaluation"]},

        { "anchor" : "Gemini3", "title" : "Mission-Specific Documentation: Gemini 3", "targets" : ["Gemini 3"] },
        { "anchor" : "Gemini4", "title" : "Mission-Specific Documentation: Gemini 4", "targets" : ["Gemini 4"] },
        { "anchor" : "Gemini5", "title" : "Mission-Specific Documentation: Gemini 5", "targets" : ["Gemini 5"] },
        { "anchor" : "Gemini6", "title" : "Mission-Specific Documentation: Gemini 6", "targets" : ["Gemini 6", "Gemini 6A"] },
        { "anchor" : "Gemini7", "title" : "Mission-Specific Documentation: Gemini 7", "targets" : ["Gemini 7"] },
        { "anchor" : "Gemini8", "title" : "Mission-Specific Documentation: Gemini 8", "targets" : ["Gemini 8"] },
        { "anchor" : "Gemini9", "title" : "Mission-Specific Documentation: Gemini 9", "targets" : ["Gemini 9", "Gemini 9A"] },
        { "anchor" : "Gemini10", "title" : "Mission-Specific Documentation: Gemini 10", "targets" : ["Gemini 10"] },
        { "anchor" : "Gemini11", "title" : "Mission-Specific Documentation: Gemini 11", "targets" : ["Gemini 11"] },
        { "anchor" : "Gemini12", "title" : "Mission-Specific Documentation: Gemini 12", "targets" : ["Gemini 12"] },
        
        { "anchor" : "Apollo1", "title" : "Mission-Specific Documentation: Apollo 1", "targets" : ["Apollo 1"], "keywords" : ["sunspot"] },
        { "anchor" : "AS202", "title" : "Mission-Specific Documentation: AS-202 (\"Apollo 3\")", "targets" : ["AS-202"], "keywords" : ["corona"] },
        { "anchor" : "Apollo4", "title" : "Mission-Specific Documentation: Apollo 4", "targets" : ["Apollo 4"], "keywords" : ["solarium", "solarium 55", "solarium 54"] },
        { "anchor" : "Apollo5", "title" : "Mission-Specific Documentation: Apollo 5", "targets" : ["Apollo 5"], "keywords" : ["fp2", "sunburst", "sunburst 120", "sunburst 119", "sunburst 118", "sunburst 117"] },
        { "anchor" : "Apollo6", "title" : "Mission-Specific Documentation: Apollo 6", "targets" : ["Apollo 6"], "keywords" : ["solarium", "solarium 55"] },
        { "anchor" : "2TV-1", "title" : "Mission-Specific Documentation: 2TV-1", "targets" : ["2TV-1"], "keywords" : ["sundial", "sundial e"] },
        { "anchor" : "LTA-8", "title" : "Mission-Specific Documentation: LTA-8", "targets" : ["LTA-8"], "keywords" : ["aurora"] },
        { "anchor" : "Apollo7", "title" : "Mission-Specific Documentation: Apollo 7", "targets" : ["Apollo 7"], "keywords" : ["sundisk", "sundisk 282", "sundisk 281"] },
        { "anchor" : "Apollo8", "title" : "Mission-Specific Documentation: Apollo 8", "targets" : ["Apollo 8"], "keywords" : ["colossus 1", "colossus 237", "colossus 236", "colossus 235", "colossus 234"] },
        { "anchor" : "Apollo9", "title" : "Mission-Specific Documentation: Apollo 9", "targets" : ["Apollo 9"], "keywords" : ["fp3", "fp4", "colossus 1a", "colossus 249", "colossus 248", "colossus 247", "colossus 246", "sundance", "sundance 306", "sundance 305", "sundance 304", "sundance 303", "sundance 302", "sundance 292"] },
        { "anchor" : "Apollo10", "title" : "Mission-Specific Documentation: Apollo 10", "targets" : ["Apollo 10"], "keywords" : ["fp5", "colossus 2", "comanche 45 rev 2", "comanche 45", "comanche 44", "comanche 43", "Luminary 1", "luminary 69 rev 2", "luminary 69", "luminary 68", "luminary 67", "luminary 66"] },
        { "anchor" : "Apollo11", "title" : "Mission-Specific Documentation: Apollo 11", "targets" : ["Apollo 11"], "keywords" : ["fp6", "colossus 2a", "comanche 55", "comanche 54", "comanche 53", "comanche 52", "comanche 51", "luminary 1a", "luminary 99 rev 1", "luminary 99", "luminary 98", "luminary 97", "luminary 96"] },
        { "anchor" : "Apollo12", "title" : "Mission-Specific Documentation: Apollo 12", "targets" : ["Apollo 12"], "keywords" : ["fp6", "colossus 2c", "comanche 67", "comanche 66", "comanche 65", "comanche 64", "luminary 1b", "luminary 116", "luminary 115", "luminary 114", "luminary 113", "luminary 112" ] },
        { "anchor" : "Apollo13", "title" : "Mission-Specific Documentation: Apollo 13", "targets" : ["Apollo 13"], "keywords" : ["fp7", "colossus 2d", "comanche 72 rev 3", "comanche 72", "comanche 71", "comanche 70", "luminary 1c", "luminary 131 rev 1", "luminary 131 rev 9", "luminary 130", "luminary 129"] },
        { "anchor" : "Apollo14", "title" : "Mission-Specific Documentation: Apollo 14", "targets" : ["Apollo 14"], "keywords" : ["fp7", "colossus 2e", "comanche 108", "comanche 107", "comanche 106", "comanche 105", "luminary 1d", "luminary 178", "luminary 177", "luminary 176", "luminary 175", "luminary 174", "luminary 173", "luminary 163"] },
        { "anchor" : "Apollo15", "title" : "Mission-Specific Documentation: Apollo 15", "targets" : ["Apollo 15"], "keywords" : ["fp8", "colossus 3", "artemis 72", "artemis 71", "artemis 70", "artemis 69", "luminary 1e", "luminary 210", "luminary 209", "luminary 208", "luminary 207", "luminary 206", "luminary 205"] },
        { "anchor" : "Apollo16", "title" : "Mission-Specific Documentation: Apollo 16", "targets" : ["Apollo 16"], "keywords" : ["fp8", "colossus 3", "artemis 72", "artemis 71", "artemis 70", "artemis 69", "luminary 1e", "luminary 210", "luminary 209", "luminary 208", "luminary 207", "luminary 206", "luminary 205"] },
        { "anchor" : "Apollo17", "title" : "Mission-Specific Documentation: Apollo 17", "targets" : ["Apollo 17"], "keywords" : ["fp8", "colossus 3", "artemis 72", "artemis 71", "artemis 70", "artemis 69", "luminary 1e", "luminary 210", "luminary 209", "luminary 208", "luminary 207", "luminary 206", "luminary 205"] },
        { "anchor" : "Skylab2", "title" : "Mission-Specific Documentation: Skylab 2", "targets" : ["Skylab 2"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
        { "anchor" : "Skylab3", "title" : "Mission-Specific Documentation: Skylab 3", "targets" : ["Skylab 3"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
        { "anchor" : "Skylab4", "title" : "Mission-Specific Documentation: Skylab 4", "targets" : ["Skylab 4"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
        { "anchor" : "ASTP", "title" : "Mission-Specific Documentation: ASTP", "targets" : ["ASTP"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
        
        { "anchor" : "StatusReports", "title" : "Status Reports", "keywords" : ["Status report"]},
        { "anchor" : "Press", "title" : "The Press", "keywords" : ["Press"]},
        { "anchor" : "OBC", "title" : "Gemini On-Board Computer (OBC)", "keywords" : ["OBC"]},
        { "anchor" : "IMCC", "title" : "Integrated Mission Control Center (IMCC)", "keywords" : ["IMCC"], "blurb" : blurbIMCC},
        { "anchor"  : "Fury", "title" : "Sound and Fury", "keywords" : ["Sound and fury"], "blurb" : blurbSoundAndFury },
        { "anchor"  : "Different", "title" : "Something Different", "keywords" : ["something different"], "blurb" : blurbSomethingDifferent },
         
        { "anchor" : "EngineeringDrawings", "title" : "Electrical and Mechanical Design", "keywords" : [ "Engineering Drawings", "Drawing Tree", "NARASW" ], "blurb" : blurbElectroMechanical },
        { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True, "lineNumbers" : True, "hr" : True }
    ]

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
    if len(fields) >= 8:    # Field 8
        record["Keywords"] = simpleList(fields[7].lower())
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
cutoffFiles = 25
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

