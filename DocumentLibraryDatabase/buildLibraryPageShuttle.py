#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPageShuttle.py
# Purpose:	    Module for buildLibraryPage.py that's specific to the Shuttle.
# Mod history:  2026-01-28 RSB  Split off from old buildLibraryPage.py.
#
from buildLibraryPageCommon import *

title = "Space Shuttle"

oi2sts = {
    "r16/t9": [1],
    "r18/t11": [2, 3, 4],
    "r19/t12": [5, 6, 7, 8],
    "oi-2": [9, 11, 13],
    "oi-4": [14, 17, 19, 20, 24],
    "oi-5": [22, 23],
    #"oi5-24": [26],
    "oi-6": [25],
    #"oi6-27": [27],
    #"oi6-28": [28],
    #"oi6-29": [30],
    #"oi6-30": [31],
    #"oi17-26": [33],
    #"oi17-32": [32],
    "oi-8b": [26, 27, 28, 29, 30, 33],
    "oi-8c": [31, 32, 34, 36],
    "oi-8d": [35, 38, 40, 41],
    "oi-8f": [37, 39],
    "oi-20": [42, 43, 44, 45, 48],
    "oi-21": [46, 47, 49, 50, 52, 53, 54, 55, 56],
    "oi-22": [51, 57, 58, 59, 60, 61, 62, 68],
    "oi-23": [63, 64, 65, 66, 67],
    "oi-24": [69, 70, 71, 72, 73, 74, 75, 76, 77, 78],
    "oi-25": [79, 80, 81, 82, 83, 84, 94],
    "oi-26a": [85, 86, 87, 89],
    "oi-26b": [88, 90, 91, 93, 95, 103],
    "oi-27": [92, 96, 97, 99, 101, 106],
    "oi-28": [98, 100, 102, 104, 105, 108, 109],
    "oi-29": [107, 110, 111, 112, 113],
    "oi-30": [114, 115, 116, 117, 118, 121],
    "oi-32": [120, 122, 123, 124, 125],
    "oi-33": [119, 126, 127],
    "oi-34": [128, 129, 130, 131, 132, 133, 134, 135]
    }
for oi in oi2sts:
    stsList = oi2sts[oi]
    for i in range(len(stsList)):
        sts = stsList[i]
        if isinstance(sts, int):
            stsList[i] = "sts-%d" % sts
        else:
            stsList[i] = "sts-%s" % sts.lower()

# Here are various HTML blurbs that head up individual sections of the 
# document we're going to output.

blurbTop = """ 
This is our library of Space Shuttle documents related in some way to the 
onboard computer systems.  See also <a href="Shuttle.html">Space Shuttle
page</a>.
Our other libraries are:
<ul>
<li><a href="links2.html">Gemini, Apollo, and Skylab library page</a></li>
<li><a href="links-probes.html">Space Probes and Satellites library page</a></li>
</ul>
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
you mostly need to know that the columnar data is tab-delimited. There's 
actually a full explanation <a href="https://github.com/virtualagc/virtualagc/blob/gh-pages/DocumentLibraryDatabase/DatabaseMaintenance.md">here</a>,
but I can't imagine you'll want to read it.)
<br><br>
"""

blurbRecentlyAdded = """
This section lists all documents updated in the last 
""" + "%d" % cutoffMonths + """ months
or the last """ + "%d" % cutoffFiles + """ files, whichever is greater. 
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
tableOfContentsSpec = [
    { "title" : "Debug", "sortKey" : myOriginalSortKey, "blurb" : blurbDebug },
    { "anchor" : "RecentAdditions", "title" : "Recently Added Documents as of %s" % currentDateString, "sortKey" : myRecentSortKey, "blurb" : blurbRecentlyAdded },
    { "anchor" : "flowcharts", "title" : "Design Equations and Flowcharts", "keywords" : [ "flowcharts", "flowchart", "design equations" ], "blurb" : blurbFlowcharts },
    { "anchor" : "Avionics", "title" : "Avionics", "keywords" : [ "avionics" ] },
    { "anchor" : "HAL/S", "title" : "HAL/S Language", "keywords" : [ "HAL/S" ] },
    { "anchor" : "XPL", "title" : "XPL Language", "keywords" : ["XPL" ], "blurb" : blurbXPL },
    { "anchor" : "PASS", "title" : "Primary Avionics Software System (PASS) / Primary Flight Software (PFS)", "keywords" : [ "PASS", "PFS", "RTL" ] },
    { "anchor" : "BFS", "title" : "Backup Flight System (BFS)", "keywords" : [ "BFS" ] },
    { "anchor" : "FCOS", "title" : "Flight Control Operating System (FCOS)", "keywords" : [ "FCOS" ] },
    { "anchor" : "notes", "title" : "Flight Software Waivers and User/Program Notes", "keywords" : [ "note", "notes"] },
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
    { "anchor" : 1, "title": "STS-1, Columbia" },
    { "anchor" : 2, "title": "STS-2, Columbia" },
    { "anchor" : 3, "title": "STS-3, Columbia" },
    { "anchor" : 4, "title": "STS-4, Columbia" },
    { "anchor" : 5, "title": "STS-5, Columbia" },
    { "anchor" : 6, "title": "STS-6, Challenger" },
    { "anchor" : 7, "title": "STS-7, Challenger" },
    { "anchor" : 8, "title": "STS-8, Challenger" },
    { "anchor" : 9, "title": "STS 41-A (STS-9), Columbia", "targets": ['STS-41-A', 'STS-9'] },
    { "anchor" : 11, "title": "STS 41-B (STS-11), Challenger", "targets": ['STS-41-B', 'STS-11'] },
    { "anchor" : 13, "title": "STS 41-C (STS-13), Challenger", "targets": ['STS-41-C', 'STS-13'] },
    { "anchor" : 14, "title": "STS 41-DR (STS-14), Discovery", "targets": ['STS-41-D', 'STS-41-DR', 'STS-14'] },
    { "anchor" : 17, "title": "STS 41-G (STS-17), Challenger", "targets": ['STS-41-G', 'STS-17'] },
    { "anchor" : 19, "title": "STS 51-A (STS-19), Discovery", "targets": ['STS-51-A', 'STS-19'] },
    { "anchor" : 20, "title": "STS 51-C (STS-20), Discovery", "targets": ['STS-51-C', 'STS-20'] },
    { "anchor" : 22, "title": "STS 51-E (STS-22), Challenger (Canceled)", "targets": ['STS-51-E', 'STS-22'] },
    { "anchor" : 23, "title": "STS 51-D (STS-23), Discovery", "targets": ['STS-51-D', 'STS-23'] },
    { "anchor" : 24, "title": "STS 51-B (STS-24), Challenter", "targets": ['STS-51-B', 'STS-24'] },
    { "anchor" : 25, "title": "STS 51-G (STS-25), Discovery", "targets": ['STS-51-G', 'STS-25'] },
    { "anchor" : 26, "title": "STS 51-F (STS-26), Challenger", "targets": ['STS-51-F'] },
    { "anchor" : 27, "title": "STS 51-I (STS-27), Discovery", "targets": ['STS-51-I'] },
    { "anchor" : 28, "title": "STS 51-J (STS-28), Atlantis", "targets": ['STS-51-J'] },
    { "anchor" : 30, "title": "STS 61-A (STS-30), Challenger", "targets": ['STS-61-A'] },
    { "anchor" : 31, "title": "STS 61-B (STS-31), Atlantis", "targets": ['STS-61-B'] },
    { "anchor" : 32, "title": "STS 61-C (STS-32), Columbia", "targets": ['STS-61-C'] },
    { "anchor" : 33, "title": "STS 51-L (STS-33), Challenger", "targets": ['STS-51-L'] },
    { "anchor" : 29, "title": "STS-29 (STS-29R), Discovery", "targets": ['STS-29R', "STS-29"] },
    { "anchor" : "STS29R", "title": "STS-26 (STS-26R), Discovery", "targets": ['STS-26R', 'STS-26'] },
    { "anchor" : "STS27R", "title": "STS-27 (STS-27R), Atlantis", "targets": ['STS-27R', 'STS-27'] },
    # { "anchor" : "STS29R", "title": "STS-29 (STS-29R)", "targets": ['STS-29R', 'STS-29'] },
    { "anchor" : "STS30R", "title": "STS-30 (STS-30R), Atlantis", "targets": ['STS-30R', 'STS-30'] },
    { "anchor" : "STS28R", "title": "STS-28 (STS-28R), Columbia", "targets": ['STS-28R', 'STS-28'] },
    { "anchor" : "STS34R", "title": "STS-34 (STS-34R), Atlantis", "targets": ['STS-34R', 'STS-34'] },
    { "anchor" : "STS33R", "title": "STS-33 (STS-33R), Discovery", "targets": ['STS-33R', 'STS-33'] },
    { "anchor" : "STS32R", "title": "STS-32 (STS-32R), Columbia", "targets": ['STS-32R', 'STS-32'] },
    { "anchor" : "STS36R", "title": "STS-36 (STS-36R), Atlantis", "targets": ['STS-36R', 'STS-36'] },
    { "anchor" : "STS31R", "title": "STS-31 (STS-31R), Discovery", "targets": ['STS-31R', 'STS-31'] },
    { "anchor" : 41, "title": "STS-41, Discovery" },
    { "anchor" : 38, "title": "STS-38, Atlantis" },
    { "anchor" : 35, "title": "STS-35 (STS 61-E), Columbia", "targets": ['STS-61-E', 'STS-35'] },
    { "anchor" : 37, "title": "STS-37, Atlantis" },
    { "anchor" : 39, "title": "STS-39, Discovery" },
    { "anchor" : 40, "title": "STS-40, Columbia" },
    { "anchor" : 43, "title": "STS-43, Atlantis" },
    { "anchor" : 48, "title": "STS-48, Discovery" },
    { "anchor" : 44, "title": "STS-44, Atlantis" },
    { "anchor" : 42, "title": "STS-42, Discovery" },
    { "anchor" : 45, "title": "STS-45, Atlantis" },
    { "anchor" : 49, "title": "STS-49, Endeavour" },
    { "anchor" : 50, "title": "STS-50, Columbia" },
    { "anchor" : 46, "title": "STS-46, Atlantis" },
    { "anchor" : 47, "title": "STS-47, Endeavour" },
    { "anchor" : 52, "title": "STS-52, Columbia" },
    { "anchor" : 53, "title": "STS-53, Discovery" },
    { "anchor" : 54, "title": "STS-54, Endeavour" },
    { "anchor" : 56, "title": "STS-56, Discovery" },
    { "anchor" : 55, "title": "STS-55, Columbia" },
    { "anchor" : 57, "title": "STS-57, Endeavour" },
    { "anchor" : 51, "title": "STS-51, Discovery" },
    { "anchor" : 58, "title": "STS-58, Columbia" },
    { "anchor" : 61, "title": "STS-61, Endeavour" },
    { "anchor" : 60, "title": "STS-60, Discovery" },
    { "anchor" : 62, "title": "STS-62, Columbia" },
    { "anchor" : 59, "title": "STS-59, Endeavour" },
    { "anchor" : 65, "title": "STS-65, Columbia" },
    { "anchor" : 64, "title": "STS-64, Discovery" },
    { "anchor" : 68, "title": "STS-68, Endeavour" },
    { "anchor" : 66, "title": "STS-66, Atlantis" },
    { "anchor" : 63, "title": "STS-63, Discovery" },
    { "anchor" : 67, "title": "STS-67, Endeavour" },
    { "anchor" : 71, "title": "STS-71, Atlantis" },
    { "anchor" : 70, "title": "STS-70, Discovery" },
    { "anchor" : 69, "title": "STS-69, Endeavour" },
    { "anchor" : 73, "title": "STS-73, Columbia" },
    { "anchor" : 74, "title": "STS-74, Atlantis" },
    { "anchor" : 72, "title": "STS-72, Endeavour" },
    { "anchor" : 75, "title": "STS-75, Columbia" },
    { "anchor" : 76, "title": "STS-76, Atlantis" },
    { "anchor" : 77, "title": "STS-77, Endeavour" },
    { "anchor" : 78, "title": "STS-78, Columbia" },
    { "anchor" : 79, "title": "STS-79, Atlantis" },
    { "anchor" : 80, "title": "STS-80, Columbia" },
    { "anchor" : 81, "title": "STS-81, Atlantis" },
    { "anchor" : 82, "title": "STS-82, Discovery" },
    { "anchor" : 83, "title": "STS-83, Columbia" },
    { "anchor" : 84, "title": "STS-84, Atlantis" },
    { "anchor" : 94, "title": "STS-94 (STS-83R), Columbia", "targets": ['STS-83R', 'STS-94'] },
    { "anchor" : 85, "title": "STS-85, Discovery" },
    { "anchor" : 86, "title": "STS-86, Atlantis" },
    { "anchor" : 87, "title": "STS-87, Columbia" },
    { "anchor" : 89, "title": "STS-89, Endeavour" },
    { "anchor" : 90, "title": "STS-90, Columbia" },
    { "anchor" : 91, "title": "STS-91, Discovery" },
    { "anchor" : 95, "title": "STS-95, Discovery" },
    { "anchor" : 88, "title": "STS-88/ISS-2A, Endeavour" },
    { "anchor" : 96, "title": "STS-96/ISS-2A.1, Discovery" },
    { "anchor" : 93, "title": "STS-93, Columbia" },
    { "anchor" : 103, "title": "STS-103, Discovery" },
    { "anchor" : 99, "title": "STS-99, Endeavour" },
    { "anchor" : 101, "title": "STS-101/ISS 2A.2a, Atlantis" },
    { "anchor" : 106, "title": "STS-106/ISS 2A.2b, Atlantis" },
    { "anchor" : 92, "title": "STS-92/ISS 3A, Discovery" },
    { "anchor" : 97, "title": "STS-97/ISS 4A, Endeavour" },
    { "anchor" : 98, "title": "STS-98/ISS 5A, Atlantis" },
    { "anchor" : 102, "title": "STS-102/ISS 5A.1, Discovery" },
    { "anchor" : 100, "title": "STS-100/ISS 6A, Endeavour" },
    { "anchor" : 104, "title": "STS-104/ISS 7A, Atlantis" },
    { "anchor" : 105, "title": "STS-105/ISS 7A.1, Discovery" },
    { "anchor" : 108, "title": "STS-108/ISS UF-1, Endeavour" },
    { "anchor" : 109, "title": "STS-109, Columbia" },
    { "anchor" : 110, "title": "STS-110/ISS 8A, Atlantis" },
    { "anchor" : 111, "title": "STS-111/ISS UF-2, Endeavour" },
    { "anchor" : 112, "title": "STS-112/ISS 9A, Atlantis" },
    { "anchor" : 113, "title": "STS-113/ISS 11A, Endeavour" },
    { "anchor" : 107, "title": "STS-107, Columbia" },
    { "anchor" : 114, "title": "STS-114/LF-1, Discovery" },
    { "anchor" : 121, "title": "STS-121/ULF1.1, Discovery" },
    { "anchor" : 115, "title": "STS-115/ISS 12A, Atlantis" },
    { "anchor" : 116, "title": "STS-116/ISS 12A.1, Discovery" },
    { "anchor" : 117, "title": "STS-117/ISS 13A, Atlantis" },
    { "anchor" : 118, "title": "STS-118/ISS 13A.1, Endeavour" },
    { "anchor" : 120, "title": "STS-120/ISS 10A, Discovery" },
    { "anchor" : 122, "title": "STS-122/ISS 1E, Atlantis" },
    { "anchor" : 123, "title": "STS-123/ISS 1JA, Endeavour" },
    { "anchor" : 124, "title": "STS-124/ISS 1J, Discovery" },
    { "anchor" : 126, "title": "STS-126/ISS-ULF2, Endeavour" },
    { "anchor" : 119, "title": "STS-119/ISS-15A, Discovery" },
    { "anchor" : 125, "title": "STS-125, Atlantis" },
    { "anchor" : 127, "title": "STS-127/ISS-2JA, Endeavour" },
    { "anchor" : 128, "title": "STS-128 (17A), Discovery" },
    { "anchor" : 129, "title": "STS-129/ULF3, Atlantis" },
    { "anchor" : 130, "title": "STS-130/20A, Endeavour" },
    { "anchor" : 131, "title": "STS-131/19A, Discovery" },
    { "anchor" : 132, "title": "STS-132/ULF4, Atlantis" },
    { "anchor" : 133, "title": "STS-133/ULF5, Discovery" },
    { "anchor" : 134, "title": "STS-134/ULF6, Endeavour" },
    { "anchor" : 135, "title": "STS-135/ULF7, Atlantis" },
    { "anchor" : "GOAL", "title" : "Ground Operations Aerospace Language (GOAL)", "keywords" : [ "GOAL" ] },
    { "anchor" : "ae", "title" : "Ascent/Entry Flight Techniques Panel", "keywords": ["ae"] }, 
    { "anchor" : "papers", "title" : "Papers, Articles, Presentations, Books", "keywords" : [ "papers", "paper" ] },
    { "anchor" : "studies", "title" : "Studies, Analyses", "keywords" : [ "studies" ] },
    { "anchor" : "requirements", "title" : "Requirements", "keywords" : [ "requirements" ] },
    { "anchor" : "reviews", "title" : "Reviews (FRR, LSFR, LSRR, ...)", "keywords" : [ "review", "reviews", "FRR", "LSRR", "LSFR"] },
    { "anchor" : "DevTools", "title" : "Development Tools", "keywords" : [ "dev tools" ] },
    { "anchor" : "FlightData", "title" : "Flight Data Files, Checklists, Handbooks, Procedures", "keywords" : [ "flight data" ] },
    { "anchor" : "Training", "title" : "STS Training", "keywords" : [ "crew training", "training" ] },
    { "anchor" : "FlightProcedures", "title" : "STS Flight Procedures", "keywords" : ["flight procedures" ] },
    { "anchor" : "Support", "title" : "Support Documents" , "keywords" : ["support", "support documents"] },
    { "anchor" : "Aerodynamics", "title" : "Aerodynamics", "keywords" : ["aerodynamics"] },
    { "anchor" : "Structural", "title" : "Structural Design", "keywords" : ["structural"] },
    { "anchor" : "LifeSupport", "title" : "Life Support, Environmental, Crew Station", "keywords" : ["life support"] },
    { "anchor" : "Ground", "title" : "Ground Operations and Mission Control", "keywords" : ["ground", "mcc"] },
    { "anchor" : "Administrative", "title" : "Administrative", "keywords" : ["administrative"] },
    { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True, "lineNumbers" : True, "hr" : True }
]
# Above I took some shortcuts for the STS-nnn entries, so flesh them out.
for entry in tableOfContentsSpec:
    if "anchor" not in entry:
        continue
    if isinstance(entry["anchor"], int):
        n = entry["anchor"]
        entry["anchor"] = "STS%d" % n
        if "title" not in entry:
            entry["title"] = "STS-%d" % n
    if entry["anchor"].startswith("STS"):
        if "targets" not in entry:
            entry["targets"] = [entry["anchor"].replace("STS", "STS-")]
        entry["title"] = "Flight " + entry["title"]
