This folder contains files that allow building a drawing tree.
The files have the file extension .csv to make them easier to
load/save in LibreOffice Calc, but are in fact TSV files with
fields delimited by tabs, and strings left unquoted.

There are two types of files:

	drawings.csv
	DRAWINGNUMBERPLUSREF.csv

drawings.csv is a single file containing, basically, a dump of all 
the drawing index tables from the website files AgcDrawingIndexXXXXXX.html, 
merged and sorted.  It has the fields

	URL DRAWINGNUMBER REV DOCTYPE SHEETNUM FRAMENUM TITLE NOTES

The sorting uses the keys from fields 2 (DRAWINGNUMBER) through
6 (SHEETNUM), in that order.

There is a separate DRAWINGNUMBERPLUSREF.csv file for each drawing 
relevant to this effort of expanding the drawing trees.  It is essentially 
the same as the find-table in the associated drawing, with the data 
ordered in the same way.  I.e., find numbers increase from bottom to top,
and dash numbers increase from right to left.  The column headers are the
dash numbers.  The cell entries the same as the the cells in the drawing.
In general those cell entries will be DRAWINGNUMBER[-DASHNUMBER] (with 
no REV), though I allow also the syntax of having several such items 
within the same cell, joined by " or ".

I expect there will be software (presently TBD) that uses these files
as input but produces HTML for the website.

Finally, in terms of how to produce the file drawings.csv, a method that
works for me is:

   1.	The HTML tables from AgcDrawingIndexXXXXX.html are sequentially 
   	cut-and-pasted (from SeaMonkey Composer) into a LibreOffice Calc,
   	with the column headers removed.
   2.	The data is sorted, as mentioned above, with the primary key being
   	column B and the fifth key being column F.
   3.	For data cut-and-pasted from the existing HTML indices, column A
   	will be a hyperlink, whereas we wish it instead to be just the
   	hyperlink's URL.  This can be accomplished by:
   	    a)	Saving the spreadsheet as a .fodc file (say, temp.fods).
   	    b)	Processing with:
			sed --in-place -e 's@<text:a xlink:href="@@' -e 's@" xlink:type="simple">[^<]*</text:a>@@' temp.fods
   	    c)	Reimporting temp.fods into LibreOffice Calc.
    4.	Save as drawings.csv file with a tab delimiter.
 
The drawings.csv file is relatively handy for creating a JSON file for
use with "Tipue Search".  You can do that with the MakeTipueSearch.py
script.

