#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPageProbes.py
# Purpose:	    Module for builtLibraryPage.py that's specific to robotic
#               space probes and satellite.  I.e., not human-crewed vehicles.
# Mod history:  2026-01-28 RSB  Adapted from similar files for Apollo, Shuttle.

from buildLibraryPageCommon import *

title = "Probes and Satellites"
# Here are various HTML blurbs that head up individual sections of the 
# document we're going to output.

blurbTop = """ 
This is our library of documents related in some way to the 
spaceborne computer systems of space probes and satellites.  Or more generally,
spaceborne computers for which we usually do not have any flight
software, and hence no motivation <i>yet</i> for spending effort on creating standalone
web-pages or development tools like assemblers, compilers, or CPU 
emulators. Get us the software for these computers!
Our other libraries are:
<ul>
<li><a href="links2.html">Gemini, Apollo, and Skylab library page</a></li>
<li><a href="links-shuttle.html">Space Shuttle library page</a></li>
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
<a href="DocumentLibraryDatabase/ProbesDocumentDatabase.tsv">
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

blurbHubble = """
<a href="https://en.wikipedia.org/wiki/Hubble_Space_Telescope">See the Wikipedia article.</a>
"""

blurbViking = """
<a href="https://en.wikipedia.org/wiki/Viking_program">See the Wikipedia article</a>
and <a href="https://ntrs.nasa.gov/api/citations/19880069935/downloads/19880069935_Optimized.pdf#page=159">"Viking Computer Systems" in Tomayko's <i>Computers in Spaceflight</i></a>.
<br><br>
Each of the Viking 1 and 2 missions consisted of a Mars Orbiter and a 
Mars Lander, and each of these had an onboard computer system:
<ul>
<li>Orbiter: Command Computer Subsystem (CCS), consisting of dual-redundant custom-designed 
processors identical to the CCS used in Voyager (see below).  I'm not presently
aware of any technical documentation of the CCS, beyond summaries.</li>
<li>Lander: Guidance, Control and Sequencing Computers (GCSC),
physically consisting of dual-redundant Honeywell HDC-402 computers.  Tomayko
gives us the interesting &mdash; and horrifying! &mdash; information that there
was "no adequate assembler ever written for the computer", and hence everything
needed to be hand-coded in octal.  This was a side effect of Martin Marietta's
innovative approach to writing the software in advance of specifying a CPU on
which to run the software.  That approach had the great advantage of making sure
that the required characteristics of the computer were well-known before ordering
it, but at the same time having the drawback of an often-changing instruction set
during the initial software design, thus preventing the development of an assembler.  Though
I'm not aware of surviving technical documentation for the HDC-402, there
has been online speculation that it is closely related to the Computer Control
Company's DDP-24 General Purpose Computer, a rack system with a console.
On that basis, I've included documents related to the DDP-24/124 instruction
set here.  Since the applicability of the DDP documentation is so speculative,
it may be removed at some point if more information becomes available.
Computer Control Company ads mention that the DDP-124 is "fully program
compatible with DDP-24 and DDP-224 general pupose computers", the latter of 
which was also used for various ground purposes by NASA, including mission 
simulators.</li>
</ul>
"""

blurbVoyager = """
<a href="https://en.wikipedia.org/wiki/Voyager_program">See the Wikipedia article.</a>
and <a href="https://ntrs.nasa.gov/api/citations/19880069935/downloads/19880069935_Optimized.pdf#page=176">
Chapter 6 of Tomayko's <i>Computers in Spaceflight</i></a>.
<br><br>
The Voyager 1 and 2 space probes each had 3 onboard
dual-redundant computers:  
<ul>
<li>The Computer Command System (CCS), used also in the Viking Orbiter (see above).</li>
<li>The Flight Data Subsystem (FDS)</li>
<li>The Attitude and Articulation Control System (AACS)</li>
</ul>
Numerous online sources state that the flight software was written
in Fortran 5, then later ported to Fortran 77, and still later ported somewhat
to C.  Such claims are all erroneous.
Rather, all flight software was written in the respective assembly languages.
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
    { "anchor" : "hubble", "title" : "Hubble Space Telescope", "keywords" : [ "hubble", "hst" ], "blurb" : blurbHubble },
    { "anchor" : "viking", "title" : "Viking Mars Orbiter and Lander", "keywords" : [ "viking" ], "blurb" : blurbViking },
    { "anchor" : "voyager", "title" : "Voyager Space Probes", "keywords" : [ "voyager" ], "blurb" : blurbVoyager },
    { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True, "lineNumbers" : True, "hr" : True }
]
