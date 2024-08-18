# Introduction

This is explanatory material about how to maintain the document-library pages for [Apollo/Gemini](http://www.ibiblio.org/apollo/links2.html) and [Shuttle](http://www.ibiblio.org/apollo/links-shuttle.html) on the Virtual AGC website.  Mostly, it's an explanation of the data in the the "databases" (spreadsheets, actually) which control how the document-library web-pages are formed.

This is nothing of use to anybody but a Virtual AGC website maintainer, but I've been asked about some of these details in emails, and so I thought I should preserve the answers here, in a generally-accessible form, rather than keeping them hidden in emails that nobody knows about or can access.

# General

 1. The following kinds of materials should not be added to the library:
    * If copyright is claimed ... unless the claim is clearly invalid on its face.
    * If you are personally bound by the terms of service of whoever or whatever *directly* provided you with the document.  (In other words, you are not bound by terms of service that *somebody else* agreed to ... unless that "somebody else" asks you to do so.)
    * Documents containing modern watermarks or other text not in the contemporary documents, unless such additions can be removed.
    * If without substantive difference (completeness, revision level, legibility) to some other document already in the library.
    * Documents in formats other than plain text (UTF-8) or PDF.  However, documents in (say) Microsoft Word or Power Point format can be converted to PDF for posting.
    * PDF documents without searchable text; however, searchable text can be added if doing so does not impact visual legibility.
 2. I use Google Sheets to edit the database, so for compatibility that's the safest method to use, even though other spreadsheet software (in particular, LibreOffice Calc) seems to work with the data perfectly fine.
 3. The spreadsheet has two tabs, "Main" (for Apollo and Gemini documents) and "Shuttle" (for Shuttle documents).
 4. The spreadsheet is taken out of Google Sheets for the processing that generates the document-library web-pages.
    * To export the spreadsheet from Google Sheets, select the sheet to be exported ("Main" or "Shuttle"), then from the main menu use:  File / Download / Tab Separated Values to create a file *.tsv.
    * To import the spreadsheet into Google Sheets, which should not ever be necessary, from the Sheets main menu use:  File / Import / UPLOAD.  For "Separator type" use "Tab", and uncheck the box "Convert text to numbers, dates, and formulas".
 5. The Apollo/Gemini document-library page or else the Shuttle document-library page is built from the appropriate exported *.tsv file using the buildLibraryPage.py program:
    * Apollo/Gemini:  `buildLibraryPage.py <DocumentLibraryDatabase.tsv >links2.html`
    * Shuttle:  `buildLibraryPage.py --shuttle <ShuttleDocumentDatabase.tsv >links-shuttle.html`

# The Columns of the Spreadsheet


  * "Date Added".  This should be today's date.  (It's the date used for determining whether the file is a "new addition" to the library or not.)
  * "Document Date".  Self-explanatory, I suppose.  All dates are in the form MM/DD/YYYY, but you can use MM/YYYY (automatically converted to MM/01/YYYY) or just YYYY (automatically converted to just YYYY).  Don't leave the YYYY blank, though; if you there's no date at all listed, give your best guess for a year.
  * "Document ID Num/Org".  This is where it starts to become tricky, as the documents often have several document numbers, perhaps one from the organization creating it, one from MSC or JSC, and one from NASA at large.  Often there's a stamp with a CR-xxxxxx number.  All available document numbers are entered, separated by commas.  If possible, the organization that created the document is also entered, separated from the document number by a slash.  For example:  "DocNumber1/Org1, DocNumber2/Org2, DocNumber3/Org3".  Many frequently-appearing orgs have acronyms or abbreviated forms I use over and over again, which the software understands.  Here's the current list, and if the organization isn't on it, just spell out the name, perhaps looking through the names already used in the spreadsheet.  (The current list is found in the `buildLibraryPage.py` program itself.)
    * "IL" : "MIT Instrumentation lab (AKA Charles Stark Draper Laboratory)",
    * "AC" : "AC Electronics (AKA AC Sparkplug, Delco Electronics, etc.)",
    * "MSC" : "Manned Spacecraft Center (AKA Johnson Space Center)",
    * "GAEC" : "Grumman Aerospace Engineering",
    * "NAA" : "North American Aviation (AKA North American Rockwell AKA Rockwell International)",
    * "TRW" : "TRW (AKA Thompson Ramo Wolldridge)",
    * "IBM" : "IBM Federal Systems Division",
    * "NASA" : "National Aeronautics and Space Administration (other than MSC)",
    * "JPL" : "Jet Propulsion Laboratory",
    * "Douglas" : "McDonnell Douglas",
    * "USA" : "United Space Alliance",
    * "Intermetrics" : "Intermetrics Incorporated",
    * "Rockwell" : "Rockwell International",
    * "DOD" : "United Stated Department of Defense",
    * "UT" : "University of Texas at Austin",
    * "UTC" : "United Technologies Corporation, Hamilton Standard Division",
    * "GE" : "General Electric"
  * "Revision".  Self-explanatory.  Well, I'd suggest using "Rev A" or "Rev 1.0" rather than just "A" or "1.0".  If you have several different revisions of the same document, they appear on separate rows of the spreadsheet. 
  * "Document Portion".  Leave blank for full documents.  The wording is whatever you like (but brief, please), so you can say things like "Vol 1", "Vol I/III", "Sections 1-3 only", etc.  If you have several scans of the same document, but different portions of it, then they appear on separate rows of the spreadsheet.
  * "Author Name/Org".  This is a list of those who wrote or otherwise prepared the document ... *not* of those who merely "approved" the document.  If there are no listed authors, then use the name of the organization (full name, not the abbreviated forms listed above).  If there are multiple authors, they're separated by commas.  (So be careful not to put a comma in front of Jr.!)  If you can determine the authors' organizational affiliations, then they're separated from the author name by a slash.  For example, "Glenn Minott/Rockwell, John B. Peller/Rockwell, Kenneth Cox/MSC".  If the "author" is an organization, then there's no additional organizational affiliation needed, so it's just "Rockwell International" and *not* "Rockwell International/Rockwell".
  * "Mission/Version Applicability".  Use this if the relevance is to a specific shuttle flight, like STS-121 or STS-97.  If there's more than one, separate them by commas.
  * "Keywords".  The hardest field!  This determines how the documents are grouped into sections on the library page.  You can enter as many keywords as you like, separated by commas, but if they don't correspond to the keywords recognized by the algorithm, they won't have any effect.  (Right now, at least.  You can use unknown keywords and suggest to me that I create new sections for them them, and then they would be useful!)  Here's a hard-to-read summary of the keywords in use right now, cut-and-pasted from the `buildLibraryPage.py` software.  The "title" tells which section, and the "keywords" is a list of the keywords that send the document to that section.  For example, any of the keywords "flowcharts", "flowchart", or "design equations" send a document to the "Design Equations and Flowcharts" section.  A document can be sent to as many sections as you like.

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

  * "Absolute URL".  This is the URL at which the document will be posted to the website.  It's always "https://www.ibiblio.org/apollo/Shuttle/", plus whatever the filename is.   But:
    * The URL must be mangled according to web conventions.  For example, " " is replaced by "%20".  This is hard for you to do manually.  The easiest way to do this is open a browser (like Chrome), drag the document into the browser, and then cut-and-paste whatever filename appears in the browser's URL bar.
    * If you look at the existing URLs in the spreadsheets, you may notice that many of them have "file://..." URLs from my local drive.  That's because the software is smart enough to convert those to iblibio.org URLs.  But that's only for the ones on *my* drive, and it won't be able to convert the URLs from *your* local drive.  This feature is a great time-saver, though, and if you're on Mac or Linux you can fool it into working.  (I don't think we can fool Windows as-is, since it uses the \ character as a path separator rather than the / character.)  To do so, create a folder (in any directory you like) called "sandroid.org/public_html/apollo/Shuttle/" and put all of your documents (or folders of documents) into that folder.  Then, as just mentioned, you drag the files into Chrome/Firefox/Safari, and cut-and-paste the full URL (file://...) into "Absolute URL".
    * If there are multiple postings of the same document, then they are all separated by commas and ordered in best-to-worst order.  However, I don't expect that you'll have multiple postings.  If you *do*, though, the automatic-replacement mechanism for "file://..." mentioned above won't work for them, and you'll have to explicitly have each of the individual URLs as "https://www.ibiblio.org/...".
  * "Title".  You figure this one out.
  * "From Collection or Archive".  If you want to credit whoever preserved this document all these years, you do it here.  If there are multiple URLS in the "Absolute URL" column, you have the same number of comma-separate fields in the "From Collection or Archive" column.  However, you can have blank entries.  For example, if we posted three copies, the best from UHCL, the 2nd-best from some anonymous source, and the 3rd from NTRS, then this column would be "UHCL, , NTRS".
  * "Digitized, Sponsored, ...".  Same kind of thing as "From Collection or Archive", except that it's the name of whoever sacrificed their own money or effort to get the thing digitized.
  * "Disclaimer".  This is for sources like NASM that insist you print their own advertisement legalese.  The column accepts html, so if there are hyperlinks required, you can code them in html.  There are NASM examples like that already in the spreadsheet.
  * "Notes".  This is to hold any commentary about the documents.  I use this for several things, but mostly for explaining why some boring-looking document is actually interesting, saying that "yes, this digitization is really crummy", etc.
  * The remaining 4 columns are hardly-ever used, but relate to the situation in which the document is a scan of an Apollo-era software listing, and specifically of an Apollo AGC or AEA assembly-listing.  In this case, the Virtual AGC Project may have additionally produced any or all of the following:  A transcription of the assembly-language source code; an assembly listing output by the modern assembler; a syntax-highlighted version of the source code; a numerical listing of the executable.  These columns provide a place to put links to these various items from the Virtual AGC website or GitHub repository.
