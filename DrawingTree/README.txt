*************************************************************
NOTE: The stuff in this folder is in the very early stages of 
development, so don't expect it to do anything as of yet!
The descriptions below relate to my gameplan for what I hope
it to do eventually.
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
AgcDrawingIndexXXXXXX.html, merged and sorted.  It has the fields

	URL DRAWINGNUMBER REV DOCTYPE SHEETNUM FRAMENUM TITLE NOTES

Sorting uses the keys from fields 2 (DRAWINGNUMBER) through
6 (SHEETNUM), in that order.

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

The post-processing software is drilldown.py, so look in its source code for
additional documentation.

Finally, in terms of how to produce the file drawings.csv, I used to have
a fairly manually-intensive method here that involved cut-and-pasting from
a bunch of web-pages, importing into LibreOffice Calc, exporting stuff,
running scripts on it, reimporting into Calc, and so on.  Fortunately, 
there's now just a couple of Python scripts to run to cut through all that
nonsense:

	'cd' into the VirtualAGC hd-pages repo branch
	cat AgcDrawingIndex*.html | AgcDrawingIndex.py >drawings.csv
	MakeTipueSearch.py <drawings.csv >TipueSearch/tipuesearch_content.js
	move drawings.csv into the DrawingTree/ folder of the VirtualAGC schematics repo branch

