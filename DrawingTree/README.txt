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

The sorting uses the keys from fields 2 (DRAWINGNUMBER) through
6 (SHEETNUM), in that order.

There is a separate DRAWINGNUMBERPLUSREF.csv file for each drawing 
relevant to this effort of expanding the drawing trees ... i.e., for each
assembly.  It is essentially the same as the find-table in the associated 
drawing, with the data ordered in the same way.  I.e., find numbers 
increase from bottom to top, and dash numbers increase from right to left.  
The column headers are the dash numbers.  The cell entries the same as the 
cells in the drawing. In general those cell entries will be 
DRAWINGNUMBER[-DASHNUMBER] (with no REV), though I allow also the syntax 
of having several such items within the same cell, joined by " or ".

I expect there will be software (presently TBD) that uses these files
as input but produces HTML for the website.

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

