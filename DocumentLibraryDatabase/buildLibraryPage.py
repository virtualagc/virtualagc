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
#                               and ", Jr".  More importantly, it's actually
#                               generating a lot more of the web-page now.
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

oldRemote = "http://www.ibiblio.org/apollo/"
remote = "https://www.ibiblio.org/apollo/"
local = "/home/rburkey/Desktop/sandroid.org/public_html/apollo/"
lenOldRemote = len(oldRemote)
lenRemote = len(remote)
lenLocal = len(local)

hoverColor = "#e0e0e0"
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
document.write(headerTemplate.replace("@TITLE@","Virtual AGC Project").replace("@SUBTITLE@","Document Library Page Redux"))
</script>
<br><br>
"""

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

blurbTop = """ 
This is our collection of all the documentation we've managed to
gather over the decades that bears even a passing relevance to the 
spaceborne guidance computers used in the Apollo and Gemini programs ... or at
least all of the documentation I think I'm legally able to give you at the
present time.  Some 
hints as to where to find such documentation on your own can be found on our
<a href="QuestForInfo.html">Documentation
Quest page</a>.  Our <a href="faq.html">FAQ
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
think is relatively convenient, we also usually have more information 
than we care to clutter up your screen with.  For example, we
have the sizes of the downloads, and sometimes the names of the archives from
which we extracted the documents, as well as the name of the person who either
did the scanning for us or else financially supported the scanning process.
You can see this supplemental information by hovering your mouse over the
document title's
hyperlink before clicking the link.  Similarly, if you hover the mouse over
a <code title="Organizational affiliation appears here!" style="background-color:
""" + hoverColor + """
">document number</code>
or an <code title="Organizational affiliation appears here!" style="background-color:""" + hoverColor + """
">author name</code>, 
that's highlighted as shown here, you may be
able to find out the organization that produced the document or with which
the author was affiliated. Unfortunately, this extra pop-up information 
<i>only</i> works if
you have a mouse rather than a touchscreen, since you can hover a mouse
cursor but not a finger; but that's life!
<br><br>
Another slight drawback to the way information appears in these mouse hovers,
I suppose, is that none of it shows up if you use your browser's text-search
facility.  I doubt that you'd really want to search on any of that particular
information anyway.  But you can get around that problem by downloading the
<a href="DocumentLibraryDatabase/DocumentLibraryDatabase.tsv">
spreadsheet</a> that contains all of the information used to generate this 
web-page, and you can search or sort that spreadsheet in any manner you like.
(In pulling it into your spreadsheet program, you need merely know that the
columnar data is tab-delimited.)
"""

blurbDebug = """
This section is present temporarily, only for the purpose of debugging.  It
will be removed before this auto-generated page goes live in production.
Right now, it simply lists every document in the library, in the same order
found on <a href="links.html">our 
previously-existing Document Library page</a> ... at least to the extent that
I've input the data.
"""

cutoffMonths = 3
blurbRecentlyAdded = """
This section lists all documents updated in the last 
""" + "%d" % cutoffMonths + """
months. Note that recently-added <a href="#EngineeringDrawings">G&N 
engineering drawings</a> are <i>not</i> included in the list.
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
computers covered by the Virtual AGC Project.  We don't have <i>all</i> of
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
<tr align="center"><td>Apollo 13</td><td>no</td><td>fine</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 14</td><td>no</td><td>yes</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 15</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 16</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 17</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Skylab 2</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Skylab 3</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Skylab 4</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>ASTP</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
</tbody></table><br>
The software listings below are sorted by their creation dates.  It should be noted
that there is a certain art to determining these dates, and thus the results
are somewhat subjective.  For example, the dates on the printouts were the 
dates the printouts were made ... which could sometimes even be <i>after</i> 
the mission flew.  For software revisions that were "released", we usually know
the release dates, but those were always some undetermined number of weeks 
after the software had been created, undergone testing, etc.  And for some 
engineering revisions of the software, we have no <i>specific</i> knowledge
beyond a rough timeframe.  Nevertheless, our arrangement is probably pretty
close to the objective reality (if we only knew what it was).
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
are represented in or collected documentation.
For example, there may simply be a set of mathematical equations that represent
the physics of spacecraft motion.  At the other end of the spectrum, there 
may be detailed sets of flowcharts that form an almost-complete pictorial 
representation of the
eventual computer program's control flow and handling of variables.  The
entire continuum of possibilities is represented in this section, for all of 
the types of guidance computers covered by the Virtual AGC Project.
<br><br>
Documents are sorted by publication date.
"""

blurbSGA = """
If you are interested in the mathematical underpinnings of the AGC software, 
then this amazing series of memos from MIT's Instrumentation Lab is the place 
to look.  The memos are in roughly chronological order.  It is very interesting
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
"""

blurbPcrsPcns = """
Program Change Requests (PCRs) were the official mechanism by which proposed
AGC software changes were submitted to the NASA Software Change Board (SCB) for 
approval or rejection.  I'm not sure what the distinction between a PCR and
a Program Change Notice (PCN) is. Visually they're essentially the same
thing.  In any case, the signficance is that since AGC software changes were
governed by them, knowledge of the PCRs/PCNs is of tremendous importance in 
tracking changes between LUMINARY and COLOSSUS software revisions ... or 
alternatively, of no importance whatever if you're not interested in 
understanding the evolution of LUMINARY and COLOSSUS.
<br><br>
The entries below are arranged by PCR/PCN number.
"""

blurbAnomalies = """
In this section, we cover Assembly Control Board Requests and
MIT/IL Software Anomaly Reports.  These seemed to act similarly to PCRs and 
PCNs respectively (see above), and except that for some reason approvals could 
be made by a local board at MIT/IL rather than by the higher powers at the SCB.
<br><br>
These documents have no titles as such, so the titles given below are actually
portions we've extracted from the descriptions of the problems described by 
the documents.
<br><br>
The entries below are arranged by publication date.
"""

blurbAGS = """
The entries in this section are sorted by publication date.
"""

blurbLVDC = """
We have precious little LVDC documentation, and even less LVDC software.  
The Wikipedia article on the LVDC at the time I first wrote on this subject
lamented that all of the LVDC software has probably vanished and does not exist 
any longer. Fortunately, that has turned out to be false, although there may
be enough truth in it to make us very uncomfortable.
<br><br>
The entries in this section are sorted by 
publication date.
"""

blurbElectroMechanical = """
There are two significant categories of Document Library items which cannot be
contained fully within the structure of this web page.  I refer to electrical 
and mechanical engineering drawings of the CM and LM G&N systems, primarily
by the MIT Instrumentation Laboratory, and to engineering drawings of the 
Lunar Module, primarily by Grumman Aerospace Engineering. (Drawings of the
CSM, by North American Aviation, we unfortunately have little expectation of
accessing in bulk.)  Examples of the MIT/IL drawings are the AGC circuit 
schematics or the mechanical drawings of the physical design 
of the DSKY. There are around 100,000 such drawings presently (September 2021)
in the library, with the number expected to reach around 500,000 eventually.
Therefore, they cannot each be listed here individually.
<br><br>
Large numbers of engineering drawings are presented here <i>indirectly</i>, 
in the form of "drawing trees".  For example, Apollo 11 contained 2 G&N 
systems, one for the CM (drawing 2014999-101) and one for the LM 
(drawing 6014999-091). Each of them comprises a set of drawings, one for each
of their sub-assemblies.  And each of those comprises yet another set of 
drawings, one for each of their sub-sub-assemblies.  And so on.  Only the
two top-level drawings are explicitly presented here, in the form of links to
separate "drawing tree" pages dedicated to them.  It is those separate 
drawing tree pages, rather than this Document Library page, which allow you to 
navigate throughout their drawing hierarchies.
<br><br>
To find specific engineering drawings outside the context of the drawing trees
in which they reside, however, you won't be able to browse your way through 
a sequential list of them.  Instead, I'd recommend going to our <blockquote>
<a href="TipueSearch.html">G&N engineering-drawing search engine</a>
</blockquote>
which allows you to find engineering drawings by fragments of drawing numbers 
or drawing titles.  Or you can try our <a href="ElectroMechanical.html">
Electro-Mechanical page</a>, which may provide additional resources or 
related information.
<br><br>
As for the electro-mechanical design documents which we are able to provide
explicitly here without having to use the separate search engine, I've sorted 
them for you by publication date; the undated 
documents appear at the beginning of the list.
"""

blurbEverything = """
If none of the sections above coincides with your special interests, this 
section may help.  It contains <i>every</i> item in our Document Library, 
whether or not those documents were already included in the preceding sections.
(Excluding, of course, some G&N system engineering drawings, as explained
in the immediately-preceding section.)
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
<br><br>
The entries below are sorted by publication date. Items whose publication date
is unknown appear at the very top of the list.
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
    key = myTimeReverseSortKey(record) + myDateAuthorSortKey(record)
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
    "Douglas" : "McDonnell Douglas"
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
    
def documentEntryHTML(record, showComment):    
    html = ""
    URLs = record["URLs"]
    DocumentNumbers = record["DocumentNumbers"]
    if len(DocumentNumbers) > 0:
        html += addOrg(DocumentNumbers[0])
        for m in range(1, len(DocumentNumbers)):
            html += ", " + addOrg(DocumentNumbers[m])
        html += ", "
    if record["Revision"] != "":
        html += record["Revision"] + ", "
    if "Video" in record["Keywords"]:
        html += "Video, "
    if "Transcript" in record["Keywords"]:
        html += "Transcript, "
    if "Audio" in record["Keywords"]:
        html += "Audio, "
    if "Photo" in record["Keywords"]:
        html += "Photograph, "
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
    published = makeSensiblePublicationDate(record)
    if published != "":
        html += ", " + published
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
tableOfContentsSpec = [
    { "title" : "Debug", "sortKey" : myOriginalSortKey, "blurb" : blurbDebug },
    { "anchor" : "RecentAdditions", "title" : "Recently Added Documents", "sortKey" : myRecentSortKey, "blurb" : blurbRecentlyAdded },
    { "anchor" : "Presentations", "title" : "Presentations", "sortKey" : myAuthorSortKey, "keywords" : ["Presentation"], "blurb" : blurbPresentations },
    { "anchor" : "ProgrammerManuals", "title" : "Programmers' Manuals", "keywords" : ["Programmer manual"]},
    { "anchor" : "UserGuides", "title" : "AGC Users' Guides", "keywords" : [ "AGC user guide" ] },
    { "anchor" : "GSOPs", "title" : "Guidance System Operations Plans (GSOP)", "sortKey" : myDashSortKey, "keywords" : [ "GSOP" ], "blurb" : blurbGSOPs },
    { "anchor" : "ReferenceCards", "title" : "Quick-Reference Cards, Data Cards, Cue Cards", "keywords" : ["Reference cards"]},
    { "anchor" : "PadLoads", "title" : "AGC Pad Loads", "sortKey" : myMissionSortKey, "keywords" : [ "Pad load" ], "blurb" : blurbPadloads },
    { "anchor" : "EMPs", "title" : "Erasable Memory Programs (EMP)", "keywords" : ["Erasable memory programs"]},
    { "anchor" : "AssemblyListings", "title" : "Software Listings", "keywords" : ["Assembly listing"], "blurb" : blurbAssemblyListing },
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
    { "anchor" : "PcrsPcns", "title" : "Program Change Requests (PCR) and Notices (PCN)", "sortKey" : myDashSortKey, "documentNumbers" : [ "PCR-", "PCN-"], "blurb" : blurbPcrsPcns  },
    { "anchor" : "Anomalies", "title" : "Software Anomaly Reports and Assembly Control Board Requests", "blurb" : blurbAnomalies, "documentNumbers" : [ "LNY-", "L-", "COL-", "COM-", "A-" ] },
    { "anchor" : "SCB", "title" : "Software Control Board (SCB)", "keywords" : ["SCB"]},
    { "anchor" : "SDP", "title" : "Software Development Plans", "keywords" : ["SDP"]},
    { "anchor" : "Experience", "title" : "Apollo Experience Reports", "keywords" : ["Experience report"]},
    { "anchor" : "AGS", "title" : "Abort Guidance System (AGS)", "blurb" : blurbAGS, "keywords" : [ "AGS" ] },
    { "anchor" : "LVDC", "title" : "Launch Vehicle Digital Computer (LVDC) and Friends", "blurb" : blurbLVDC, "keywords" : [ "LVDC", "LVDA", "FCC", "IU" ] },
    { "anchor" : "SystemsHandbooks", "title" : "Systems Handbooks", "keywords" : ["systems handbook"]},
    { "anchor" : "OperationsHandbooks", "title" : "Operations Handbooks", "keywords" : ["operations handbook"]},
    { "anchor" : "OperationalDataBooks", "title" : "Operational Data Books", "keywords" : ["operational data book"]},
    { "anchor" : "CrewDebriefing", "title" : "Technical Crew Debriefings", "keywords" : ["Debriefing"]},
    { "anchor" : "Postflight", "title" : "Mission Reports and Trajectory Reconstructions", "keywords" : ["Mission report", "Trajectory reconstruction"]},
    { "anchor" : "FlightPlan", "title" : "Flight Plans", "keywords" : ["flight plan"]},
    { "anchor" : "FlightData", "title" : "Flight Data Files (Checklists, G&N Dictionaries, ...)", "keywords" : ["flight data"]},
    { "anchor" : "SpacecraftFamiliarization", "title" : "Spacecraft Familiarization Manuals", "keywords" : ["spacecraft familiarization"]},
    { "anchor" : "FlightEvaluation", "title" : "Launch Vehicle and Spacecraft Flight Evaluation Reports", "keywords" : ["flight evaluation"]},
    
    { "anchor" : "Apollo1", "title" : "Mission-Specific Documentation: Apollo 1", "targets" : ["Apollo 1"] },
    { "anchor" : "AS202", "title" : "Mission-Specific Documentation: AS-202 (\"Apollo 3\")", "targets" : ["AS-202"] },
    { "anchor" : "Apollo4", "title" : "Mission-Specific Documentation: Apollo 4", "targets" : ["Apollo 4"] },
    { "anchor" : "Apollo5", "title" : "Mission-Specific Documentation: Apollo 5", "targets" : ["Apollo 5"] },
    { "anchor" : "Apollo6", "title" : "Mission-Specific Documentation: Apollo 6", "targets" : ["Apollo 6"] },
    { "anchor" : "2TV-1", "title" : "Mission-Specific Documentation: 2TV-1", "targets" : ["2TV-1"] },
    { "anchor" : "Apollo7", "title" : "Mission-Specific Documentation: Apollo 7", "targets" : ["Apollo 7"] },
    { "anchor" : "Apollo8", "title" : "Mission-Specific Documentation: Apollo 8", "targets" : ["Apollo 8"] },
    { "anchor" : "Apollo9", "title" : "Mission-Specific Documentation: Apollo 9", "targets" : ["Apollo 9"] },
    { "anchor" : "Apollo10", "title" : "Mission-Specific Documentation: Apollo 10", "targets" : ["Apollo 10"] },
    { "anchor" : "Apollo11", "title" : "Mission-Specific Documentation: Apollo 11", "targets" : ["Apollo 11"] },
    { "anchor" : "Apollo12", "title" : "Mission-Specific Documentation: Apollo 12", "targets" : ["Apollo 12"] },
    { "anchor" : "Apollo13", "title" : "Mission-Specific Documentation: Apollo 13", "targets" : ["Apollo 13"] },
    { "anchor" : "Apollo14", "title" : "Mission-Specific Documentation: Apollo 14", "targets" : ["Apollo 14"] },
    { "anchor" : "Apollo15", "title" : "Mission-Specific Documentation: Apollo 15", "targets" : ["Apollo 15"] },
    { "anchor" : "Apollo16", "title" : "Mission-Specific Documentation: Apollo 16", "targets" : ["Apollo 16"] },
    { "anchor" : "Apollo17", "title" : "Mission-Specific Documentation: Apollo 17", "targets" : ["Apollo 17"] },
    { "anchor" : "Skylab2", "title" : "Mission-Specific Documentation: Skylab 2", "targets" : ["Skylab 2"] },
    { "anchor" : "Skylab3", "title" : "Mission-Specific Documentation: Skylab 3", "targets" : ["Skylab 3"] },
    { "anchor" : "Skylab4", "title" : "Mission-Specific Documentation: Skylab 4", "targets" : ["Skylab 4"] },
    { "anchor" : "ASTP", "title" : "Mission-Specific Documentation: ASTP", "targets" : ["ASTP"] },
    
    { "anchor" : "StatusReports", "title" : "Status Reports", "keywords" : ["Status reports"]},
    { "anchor" : "EngineeringDrawings", "title" : "AGC Electrical and Mechanical Design", "keywords" : [ "Engineering Drawings", "Drawing Tree" ], "blurb" : blurbElectroMechanical },
    { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True }
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
        record["Targets"] = simpleList(fields[6].lower())
    if len(fields) >= 8:    # Field 8
        record["Keywords"] = simpleList(fields[7].lower())
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

# Step 3:  Analyze records[] to determine what sections we will need in the
# output HTML, and the criteria for adding any given record to a section.  Note
# that there will always be a "Recent Additions" (or similarly-named) section,
# regardless of the targets and keywords defined in the database.

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
    print("<h1>" + tableOfContentsSpec[0]["title"] + "</h1>")
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
    print("<h1>" + tableOfContentsSpec[1]["title"] + " (%s)</h1>" % currentDateString)
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
                print("</ul>")
            print("<i>Added " + recordDateString + "</i><ul>")
            inUL = True
            lastDateString = recordDateString
        print("<li>", end="")
        #print("\"" + myRecentSortKey(record) + "\"<br>")
        print(documentEntryHTML(record, False), end="")    
        print("</li>")
    if inUL:
        print("</ul>")

# Step 5B:  Output all other sections, based on the parameters in 
# tableOfContentsSpec[].  
for n in range(2, len(tableOfContentsSpec)):
    if "anchor" not in tableOfContentsSpec[n]:
        continue
    # Convert all keywords and targets being searched for to lower case.
    for key in [ "keywords", "targets" ]:
        if key in tableOfContentsSpec[n]:
            values = tableOfContentsSpec[n][key]
            for m in range(len(values)):
                values[m] = values[m].lower()
            tableOfContentsSpec[n][key] = values
    print("<a name=\"" + tableOfContentsSpec[n]["anchor"] + "\"></a>")
    print("<h1>" + tableOfContentsSpec[n]["title"] + "</h1>")
    if "blurb" in tableOfContentsSpec[n]:
        print(tableOfContentsSpec[n]["blurb"])
    if "none" in tableOfContentsSpec[n] and tableOfContentsSpec[n]["none"]:
        continue
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
            print("<li>" + documentEntryHTML(record, True) + "</li>")
    print("</ul>")

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