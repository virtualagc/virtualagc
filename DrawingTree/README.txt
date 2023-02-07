*************************************************************
NOTE: The work in this folder has now been completed, but 
it's unclear if I ever updated this documentation (which I 
wrote during the implementation process) to reflect 100% how
it ended up working.  I sure hope I did!
*************************************************************

This folder contains files that allow building a drawing tree.
The files have the file extension .csv to make them easier to
load/save in LibreOffice Calc, but are in fact TSV files with
fields delimited by tabs, and strings left unquoted.

There are two types of files:

	drawings.csv
	DRAWINGNUMBERPLUSREF.csv

drawings.csv is a single file containing, basically, a dump of all 
the drawing index tables from the Virtual AGC website files 
AgcDrawingIndexXXXXXX.html, merged and sorted.  It basically has
the fields

	URL DRAWINGNUMBER REV DOCTYPE SHEETNUM FRAMENUM TITLE NOTES

Sorting uses the keys from fields 2 (DRAWINGNUMBER) through
6 (SHEETNUM), in that order.

However, there is one complication in the format of drawings.csv,
in that if implemented straightforwardly as described above, the 
URLs end up taking about 40% of the file, while actually contributing
much less than that in terms of information.  The biggest offenders
are archive.org URLs of the form

	...#page/nN/mode/1up
	
where N is an integer.  As a space-saving measure, URLs not matching
this pattern are used as is, but URLs matching the pattern are 
significantly altered and shortened.  In such URLs, the suffix "/mode/1up" 
is stripped away.  Moreover, the unique values of for the prefixes "...#page/n"
are stored at the very beginning of the file (one prefix per line),
while the individual URLs are instead prefixed by "@P@", where
P is the index (0, 1, 2, ...) into the list of unique prefixes.
For example, at the moment I'm writing this, drawings.csv looks 
like the following:

	https://archive.org/stream/AgcApertureCardsBatch7Images#page/n
	https://archive.org/stream/AgcApertureCardsBatch6Images#page/n
	https://archive.org/stream/AgcApertureCardsBatchStewart#page/n
	.
	.
	.
	@0@0	1000000	AE	1	1	1	APOLLO GUIDANCE&NAVIGATION SYSTEMS INDEX	
	@0@1	1000000	AG	1	0	1	APOLLO GUIDANCE&NAVIGATION SYSTEMS INDEX	
	@1@0	1000000	AG	1	3	1	APOLLO GUIDANCE&NAVIGATION SYSTEMS INDEX	
	.
	.
	.
	
The three URLs shown have to be translated by downstream software as:

	@0@0 -> https://archive.org/stream/AgcApertureCardsBatch7Images#page/n0/mode/1up
	@0@1 -> https://archive.org/stream/AgcApertureCardsBatch7Images#page/n1/mode/1up
	@1@0 -> https://archive.org/stream/AgcApertureCardsBatch6Images#page/n0/mode/1up

This "compression" of the URLs is not meant to affect the end drilldown
HTML files produced, but does affect the search engine (specifically the
search engine's tipuesearch_content.js file), since the entire modification
for the compression is to reduce the bandwidth and memory of the search 
engine.  The search engine thus performs the URL translation to achieve
the full URL only at the time it displays search results, and at all other
times maintains only the shortened versions of the URLs.

There is a separate DRAWINGNUMBERPLUSREF.csv file for each drawing 
relevant to this effort of expanding the drawing trees ... i.e., for each
assembly.  It is essentially the same as the "find" table in the associated 
drawing, though with some additional flexibility in ordering.  The 
first line of the file describes the type of data in each column, but 
other than that restriction the columns and rows can be in any convenient
order.  Usually, but not always, it will be most convenient for the 
rows and columns to be in the same order as in the drawing itself, because
that allows for the easiest data entry and proofing.

The column headings are the dash-number of the configuration described by
the column, and will almost always be of the form "-011", "-021", "-031",
and so forth.  (If these are shortened to "-11", "-21", ..., that's okay,
since the post-processing software will pad the fields properly anyway.)
Other possible column headings are:

	"FIND"		The find-numbers of the rows.
	"DRAWING"	The drawing numbers appearing in the rows.
	"QTY"		The quantities of the assemblies in the rows.
	"TITLE"		The titles of the drawings/assemblies in the rows.
	"STRIKE"	If non-empty (say, "X") indicates a struck-out row.
			(I.e., discard the row.)
	"NOTE"		Text present in this field will be added to the
			similarly named column in the HTML drilldown files.

Sometimes it is helpful to create an empty .csv file for a drawing which
drilldown.py might otherwise interpret as an assembly, but which isn't
actually an assembly.  (Specifically, if the title of the drawing contains
the string "ASSEMBLY" or "ASSY".)

If a .csv file has been proofed, by which I mean that the drawing numbers
and quantities have been proofed --- proofing of the titles doesn't seem too
important, since most of them will be replaced by the titles from drawings.csv
anyway --- it is useful to annotate the .csv file with an extra line in 
which 
	TITLE			=	PROOFED
	FIND			=	REF
	STRIKE			=	X
	all proofed columns 	=	X (or if QTY, 0)
Since such lines are "struck out", they are ignored by drilldown.py and thus
don't affect the HTML or JSON produced.  However, they're useful in keeping
track of what has been accomplished.  Besides that, you can have a systematic
process for proofing all unproofed files with a command like the following,
that finds every unproofed file and successively opens them in LibreOffice Calc:

	cd DrawingTree
	for n in `grep --ignore-case --files-without-match -P '\tPROOFED\t' *.csv`
	do 
		# Make sure to ignore empty files.
		if [[ `stat -c%s $n` -gt 1 ]]
		then 
			libreoffice --calc $n
		fi
	done

There are find-tables in the drawings of two essentially different types,
and the post-processing software handles both types, which it distinguishes
by the presence of the DRAWING/QTY columns:

	DRAWING present, QTY absent:	The quantities are listed in the cells.
	DRAWING absent, QTY present:	The drawing-numbers are listed in the cells.

It is also theoretically possible to have a case (though I haven't seen one 
yet) which is a hybrid, and some cells need to specify both the drawing number
and the quantity.  In that case, the cell is formatted as "DRAWING,QTY"
(with no spaces around the comma).

Wherever possible, the post-processing software takes drawing/assembly titles
from the drawings.csv file.  However, it is still advisable to have the TITLE
column, in case the corresponding drawing happens to be missing from the collection
and thus to be missing from drawings.csv.

In some cases, the DRAWING column (or the drawing numbers listed in the cells)
may have several equally-valid alternatives, in which case that are separated
by " or ".  For example, "DRAWING1 or DRAWING2 or DRAWING3".  In cases where
the cell needs to specify both the drawing and quantity, this would instead be
"DRAWING1 or DRAWING2 or DRAWING3,QTY".  I.e., the same quantity applies whatever
the number of alternative drawings.

Sometimes, the part number is formed by some complicated rule which is difficult
to specify properly in this kind of format, such as "Look up in table X of
drawing Y, using table Z".  Therefore, the drawing number sometimes cannot 
necessarily be generated automatically by software and is simply left as a 
textual description of the rule.

At its simplest, the post-processing to create drawing indexes and drilldown
files is this:

	cd DrawingTree
	./makeAllDrilldowns.sh

This is based on a couple of Python 3 programs, DrawingTree/drilldown.py, and
(in the gh-pages branch) Scripts/AgcDrawingIndex.py, so you can look in their
source code for additional documentation.  

For drilldown.py, basically:

	cd DrawingTree
	./drilldown.py ASSEMBLYNAME >OUTPUT.html
			or possibly
	python3 ./drilldown.py ASSEMBLYNAME > OUPUT.html

where ASSEMBLYNAME.csv is one of the existing FIND-table files.  The OUTPUT.html
file is constructed in such a way that it can be browse directly from this
directory or else can be used on the Virtual AGC website, though the formatting
differs in the two cases.  (In other words, it can be used both by me, for 
updating stuff on the website, and by downstream users, for generating locally
browsable drilldowns of whatever assembly they need.)  This process also creates 
a file,

	drilldown-ASSEMBLYNAME.json

which is a machine-readable form of the data in the OUTPUT.html file, except that
it additionaly contains quantity data for each FIND number.

As for how to produce the file drawings.csv, I used to have
a fairly manually-intensive method here that involved cut-and-pasting from
a bunch of web-pages, importing into LibreOffice Calc, exporting stuff,
running scripts on it, reimporting into Calc, and so on.  Fortunately, 
there's now just a couple of Python scripts to run to cut through all that
nonsense, so makeAllDrilldowns.sh does it something like this:

	'cd' into the VirtualAGC gh-pages repo branch
	cat AgcDrawingIndex*.html | AgcDrawingIndex.py >drawings.csv
	MakeTipueSearch.py <drawings.csv >TipueSearch/tipuesearch_content.js
	move drawings.csv into the DrawingTree/ folder 
		of the VirtualAGC schematics repo branch

