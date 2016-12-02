# Introduction

The problem being addressed is that regardless of the specific technique used to produce the
AGC source code files from the AGC assembly listings (the theoretically-available techniques
being keyboard entry, voice recognition, and optical character recognition), the source code
files are nevertheless imperfect representations of the original due to the inevitable errors
such as typos introduced by the data-entry procedure.  The correctness of the source code proper
itself is of little concern, since ultimately it is always eventually assembled into executable
"octal rope" form, and can be compared in this form to known-good octal ropes, and hence there
is a deterministic (and relatively efficient) process for repairing the source code's errors.
However, the correctness of the transcribed AGC program's _comments_ is always a concern, since 
the comments do not contribute to the octal rope.  There is no satisfactory process for finding errors 
in the comments ... one is reduced either
to reading and re-reading the comments, or else trying to locate some of the 
errors by cross-comparisons between different versions of the same AGC program.  But either process
is dubious in terms of the confidence one can have in them, and there is no metric other than
the sheer number of hours spent on the task that can be applied to give you any greater confidence.

The program ProoferComments.py is a tool which, with some luck, we might be able to use to
make the proofing process for the AGC program comments managable. By "proofing", I mean checking for
checking for discrepancies between the original AGC assembly listings and the transcribed
(ASCII) AGC source.  The tool is (at this point) applicable only to the textual content of 
the program comments, and ignores all white space (i.e., columnar alightment of the text), though in
theory it may eventually be usable to address column-alignment as well.

To give some idea of the scale of the problem and of the effectiveness of ProoferComments.py for 
addressing it, yesterday I transcribed the P40-47 log section of Luminary 210 from the scanned
page imagery of that program into source code.  The source code is _almost_ identical to the 
pre-existing corresponding section from Luminary 131, which had been available for 13 years at that
point and had been subject, presumably, to scrutiny by many people.  Because the code was pre-existing,
I was free to concentrate on detailed correction of the comments in the code rather than the physical
effort of transcription, and I found and corrected many such errors.  _After_ the transcription was
complete, I checked it with ProoferComments.py and immediately found and corrected 34 more errors in
that way.  It so happens that the P40-47 log section has 34 pages, so what I had found (and corrected
with the assistance of ProoferComments.py) one additional error per page, in spite of my best efforts
to previously eliminate the errors by visual inspection.  Admittedly, many of these errors were trivial,
but some were quite important ... and a couple of fixes were even to restore typos made by the original
AGC developers, which I had accidentally removed before.  :-)

# A Way to Drastically Speed Up Proofing, With Much-Improved Confidence in the Results

In this method, we start with high-quality B&W versions of an AGC program listing, as created
by octopus.py or some suitable cousin of it.  This imagery is cropped or masked, hopefully automatically,
in such a way that _only_ the program comments remain.

Another component needed to complete the task is the transcribed AGC source files which are being checked.
The _must_ have been input in such a way that all of the original comments (i.e., those in the scanned
assembly listings) are prefixed by "#", whereas all "modern" comments added later are prefixed instead
by "##".

For any given scanned AGC page, what ProoferComments.py does is this:

1. From the B&W cropped image containing only comments, used the Tesseract OCR engine
   to determined the positions ("bounding boxes") of every character.  Primitive 
   optical character recognition is coincidentally performed as a byproduct, but 
   having this OCR data is not essential to the process.
2. From the transcribed AGC source code, discards all of the blank lines, modern comments
   ("##"), and source code, leaving just the original comments, minus the "#" we've added
   to them in transcription.  A new graphical image is produced, consisting simply of all
   these remaining comment characters, _positioned and scaled to fit the bounding boxes_
   described above. These comment characters are rendered in color (i.e., not in black),
   typically in dark green, but in red if it so happens that they don't match the character
   guessed by Tesseract in the step above.  That the images are in color is essential;
   that the color _differs_ depending on whether or not Tesseract's guesses correspond to them
   is not essential, but is useful.
3. Overlays the original B&W image atop this newly-created image, and saves this final
   result.

The result of such a procedure is a new graphics file, similar to the original B&W octal images,
except that at positions where the transcripion of the source code _doesn't match_ the original
scan, there will be a blob that doesn't look like an alphanumeric character, in some montage of 
black, red, and green; where the transcription
does match the scan, there will be an alphanumeric character, in black.

Thus the proofing process is no longer a matter of _comparing_ the transcribed source code to
the original scans, but rather simply of examining the images to see whether the look like black
alphanumerics, or whether they look like colored blobs.  Needless to say, this is a visual
inspection which a human being can perform quite rapidly.

# The Method Adopted by ProoferComments.py

## Rationale

ProoferComments.py creates a "combined image" as described in the preceding section for a 
single page of B&W comments, given the source-code files corresponding to the AGC program.

Because the font used in the AGC assembly-listing printouts does not correspond to any
readily-available modern font (as far as I can tell), ProoferComments.py relies on having a
set of pre-generated PNG files, two for each alphanumeric character plus certain punctuation.
Only the characters actually found in the printouts are supported, so that all of the capital
letters are represented, but non of the lower-case letters are.  One of these PNG files is a color indicating a match with
Tesseract, usually dark green, and other is in a color indicating a non-match with Tesseract, 
generally red.  These are all stored in the asciiFont/ folder, and have names like matchN.png
and nomatchN.png, where N is the decimal value of the ASCII code for that character.  For 
example, match65.png is a green capital-A.

## Preparation of the Individual Character PNG Files

These files are all created by loading B&W AGC scan pages into GIMP, finding good-looking
examples of the desired characters, and cutting them out as new images.  They are also
typically repaired on a pixel-by-pixel basis, and converted to bi-level B&W.
Because ProoferComments.py scales the digits appropriately, and because the fonts of 
almost all of the AGC assembly listing printouts are almost identical, I expect that
the octal-digit files only need to be created once, although in principle they could be
prepared separately for every AGC printout.

EVERYTHING BELOW THIS HAS NOT YET BEEN CORRECTED.

## Theory of Operation

ProoferBox.py uses the [Tesseract OCR engine](https://github.com/tesseract-ocr), but not
for OCR'ing, and no "training" of the engine is needed.  Rather, Tesseract's ability to create
"bounding boxes" for all of the characters in the B&W octals image, and to output that data in
machine readable form, is used.

The bounding boxes found by Tesseract (in a high-quality B&W image) are in 1-to-1 correspondence
with the digits in a binsource file (assuming that the binsource option PARITY=1 is used).  What
ProoferBox.py does is to simply position the 0t.png, 1t.png, ... files mentioned in the
preceding section, into the bounding boxes, scaling them appropriately.  

As a supplementary feature, if the octal digit Tesseract expects to find there does not agree
with the binsource file for a given box, the colored 0m.png, 1m.png, ... file is used instead,
to make it stand out even more in the composite image.

# Requirements for ProoferBox.py

* Python 2.5
* [Wand 0.4.4](http://docs.wand-py.org)
* [ImageMagick](http://www.imagemagick.org)
* [Tesseract OCR engine](https://github.com/tesseract-ocr)

Beware of the ghastly 
tendency of some Linux distributions (if you're using Linux) to install GraphicsMagick
in place of ImageMagick, whilst pretending that ImageMagick is what has been installed.
I don't know of any of this works with GraphicsMagick, and don't care.

# Usage of ProoferBox.py

ProoferBox.py requires the files 0t.png, ..., 7t.png, 0m.png, ..., 7m.png, and octals
to reside within the same folder, as is the case in the source distribution, and this should
be the current working directory when ProoferBox.py is actually run.  However,
input and output files for it can reside an any other folder.

     ./ProoferBox.py BWINPUTIMAGE OUTPUTIMAGE BANK PAGEINBANK BINSOURCE

The command-line parameters are:

* `BWINPUTIMAGE` is the pathname to a B&W page of octals, as prepared by octopus.py.
* `OUTPUTIMAGE` is the pathname to where the composite image for proofing will be written.
* `BANK` is the AGC memory-bank number, from 0 to 35 decimal.  Octal values would be misinterpreted.
* `PAGEINBANK` is the printout-page within the memory bank, from 0 to 3.
* `BINSOURCE` is the pathname to the AGC program's binsource file, the file whose contents are being proofed.

Here is a simple bash script that applies ProoferBox.py to a complete set of B&W octal 
pages:

	pageNum=STARTINGPAGEOFOCTALS
	for bank in 2 3 0 1 `seq 4 35`
	do
		for pageInBank in 0 1 2 3
		do 
			./ProoferBox.py BWIMAGEDIR/$pageNum.tif OUTPUTDIR/$pageNum.png $bank $pageInBank PATHTOBINSOURCEFILE
			pageNum=$((pageNum+1))
		done
	done
