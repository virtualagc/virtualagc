#!/usr/bin/python3
# By Ronald S. Burkey <info@sandroid.org>, placed in the Public Domain.
# 
# Filename:     buildLibraryPageApollo.py
# Purpose:	    Module for buildLibraryPage.py that's specific to 
#               Apollo+Gemini.
# Mod history:  2026-01-28 RSB  Split off from old buildLibraryPage.py.

from buildLibraryPageCommon import *

title = "Gemini, Apollo, and Skylab"

# Here are various HTML blurbs that head up individual sections of the 
# document we're going to output.

blurbTop = """ 
<i>(Our <a href="links.html">old version of this page</a> is still available, 
but not likely to be updated in the future.)</i>  
This segment of the library is specific to the Gemini, Apollo, and Skylab projects. Our other
libraries are:
<ul>
<li><a href="links-shuttle.html">Space Shuttle library page</a></li>
<li><a href="links-probes.html">Space Probes and Satellites library page</a></li>
</ul>
Welcome to the Virtual AGC Document Library.  New submissions are 
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
you mostly need to know that the columnar data is tab-delimited. There's 
actually a full explanation <a href="https://github.com/virtualagc/virtualagc/blob/gh-pages/DocumentLibraryDatabase/DatabaseMaintenance.md">here</a>,
but I can't imagine you'll want to read it.)
"""

blurbRecentlyAdded = """
This section lists all documents updated in the last 
""" + "%d" % cutoffMonths + """ months or the last """ + \
"%d" % cutoffFiles + """ files, whichever is greater. Note that recently-added <a href="#EngineeringDrawings">G&N 
engineering drawings</a> may not be included in the list.
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
the software.  Or perhaps for which we have only a binary, without source
code.  And, there are missions for which we may not have the <i>exact</i>
software revision originally used, but do have a revision which is "fine" for
successfully flying a simulated mission.  Here's a mission-by-mission
summary of what we presently have and don't have:<br><br>
<table cellspacing="2" cellpadding="2" border="1" align="center" style="font-family:sans-serif"><tbody>
<tr style="font-weight:bold" align="center"><td>Mission</td><td>CM AGC</td><td>LM AGC</td><td>AGS</td><td>LVDC</td></tr>
<tr align="center"><td>AS-202</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 1</td><td>partial</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 4</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 5</td><td>n/a</td><td>yes</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 6</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 7</td><td>no</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 8</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Apollo 9</td><td>yes</td><td>fine</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 10</td><td>yes</td><td>yes</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 11</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 12</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 13</td><td>yes</td><td>yes</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 14</td><td>no</td><td>yes</td><td>no</td><td>no</td></tr>
<tr align="center"><td>Apollo 15</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 16</td><td>yes</td><td>yes</td><td>yes</td><td>no</td></tr>
<tr align="center"><td>Apollo 17</td><td>yes</td><td>yes</td><td>yes</td><td>yes</td></tr>
<tr align="center"><td>Skylab 1</td><td>n/a</td><td>n/a</td><td>n/a</td><td>yes</td></tr>
<tr align="center"><td>Skylab 2</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Skylab 3</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>Skylab 4</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
<tr align="center"><td>ASTP</td><td>yes</td><td>n/a</td><td>n/a</td><td>no</td></tr>
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

blurbDanceMemos = """
The "DANCE Memos" are internal memos from the MIT Instrumentation Laboratory 
dealing with issues of SUNDANCE software development.  The items are arranged according to their memo numbers.
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

blurbSkylab = """
This section is devoted to Skylab-related documents in general, since so
many of them were either common to all Skylab missions, or at least can't 
be confidently associated with any specific mission.
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
    { "anchor" : "MissionTechniquesMemos", "title" : "Mission Techniques and Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["Mission Techniques Memo"], "keywords" : ["Mission Techniques"] },
    { "anchor" : "SystemTestGroupMemos", "title" : "System Test Group Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["System Test Group Memo"] },
    { "anchor" : "Requirements", "title" : "AGC/AGS Software Requirements", "keywords" : ["Software requirements"]},
    { "anchor" : "DanceMemos", "title" : "DANCE Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["DANCE Memo"], "blurb" : blurbDanceMemos },
    { "anchor" : "LuminaryMemos", "title" : "LUMINARY Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["LUMINARY Memo"], "blurb" : blurbLuminaryMemos },
    { "anchor" : "ColossusMemos", "title" : "COLOSSUS Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["COLOSSUS Memo"] },
    { "anchor" : "SkylarkMemos", "title" : "SKYLARK (SKYLAB) Memos", "sortKey" : myDocSortKey, "documentNumbers" : ["SKYLARK Memo", "SKYLAB Memo"] },
    { "anchor" : "PcrsPcns", "title" : "Program Change Requests (PCR) and Notices (PCN)", "sortKey" : myDashSortKey, 
                    "documentNumbers" : [ "PCR-", "PCN-"], "blurb" : blurbPcrsPcns  },
    { "anchor" : "Anomalies", "title" : "Software Anomaly Reports and Assembly Control Board Requests", "sortKey" : myAnomalySortKey, 
                    "blurb" : blurbAnomalies, "documentNumbers" : [ "ACB-", "LNY-", "L-", "COL-", "COM-", "A-", "Y-" ] },
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
    { "anchor" : "Skylab1", "title" : "Mission-Specific Documentation: Skylab 1", "targets" : ["Skylab 1"], },
    { "anchor" : "Skylab2", "title" : "Mission-Specific Documentation: Skylab 2", "targets" : ["Skylab 2"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
    { "anchor" : "Skylab3", "title" : "Mission-Specific Documentation: Skylab 3", "targets" : ["Skylab 3"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
    { "anchor" : "Skylab4", "title" : "Mission-Specific Documentation: Skylab 4", "targets" : ["Skylab 4"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
    { "anchor" : "ASTP", "title" : "Mission-Specific Documentation: ASTP", "targets" : ["ASTP"], "keywords" : ["skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45"] },
    
    { "anchor" : "StatusReports", "title" : "Status Reports", "keywords" : ["Status report"]},
    { "anchor" : "Tindallgrams", "title" : "Tindallgrams", "keywords" : ["Tindallgrams"]},
    { "anchor" : "Press", "title" : "The Press", "keywords" : ["Press"]},
    { "anchor" : "OBC", "title" : "Gemini On-Board Computer (OBC)", "keywords" : ["OBC"]},
    { "anchor" : "IMCC", "title" : "Integrated Mission Control Center (IMCC)", "keywords" : ["IMCC"], "blurb" : blurbIMCC},
    { "anchor" : "RTCC", "title" : "Real-Time Computer Complex (RTCC)", "keywords" : ["RTCC"] },
    { "anchor"  : "Fury", "title" : "Sound and Fury", "keywords" : ["Sound and fury"], "blurb" : blurbSoundAndFury },
    { "anchor"  : "Different", "title" : "Something Different", "keywords" : ["something different"], "blurb" : blurbSomethingDifferent },
     
    { "anchor" : "EngineeringDrawings", "title" : "Electrical and Mechanical Design", "keywords" : [ "Engineering Drawings", "Drawing Tree", "NARASW" ], "blurb" : blurbElectroMechanical },
    { "anchor" : "EverythingSkylab", "title" : "Everything Skylab", "documentNumbers" : ["SKYLARK Memo", "SKYLAB Memo"], "targets" : ["Skylab 1", "Skylab 2", "Skylab 3", "Skylab 4"], "keywords" : [ "aap", "skylab", "skylark", "skylark 48", "skylark 47", "skylark 46", "skylark 45" ], "blurb" : blurbSkylab },
    { "anchor" : "Everything", "title" : "Everything", "blurb" : blurbEverything, "all" : True, "lineNumbers" : True, "hr" : True }
]
