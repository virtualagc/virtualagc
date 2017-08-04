# Introduction

The program ProoferBox.py is a tool that I hope will greatly speed up proofing of octal 
(binsource) files, inspired by the great speed-ups in data-entry that Mike Stewart's octopus.py has
permitted for printouts that were originally on green&white paper.

The idea is this:  Regardless of the form of the original AGC assembly listing 
(i.e., whether green & white paper or else white paper with black lines), it is possible
to use octopus.py to turn the octal listings into a high-contrast pure black & white
bilevel image.  This may be used as a basis for OCR'ing the data entry in binsource form
or not, but regardless of how fast and convenient the data-entry process may become 
because of it, and no matter how error-free the resulting binsource file may be, 
the binsource file still needs to be proofed by comparison against the original data.

Furthermore, the proofing methods used up to this point, namely visual side-by-side 
comparison of the binsource vs the scanned assembly listing, or alternatively using 
text-to-speech on the binsource while visually inspecting the scanned assembly listing,
it is an extremely time-consuming and tiring process that requires anywhere from 
24 to 48 man-hours by my estimation ... which translates to weeks of calendar time, or
even months, if doesn't work at it incessantly.  Nasty!

# A Possible Way to Drastically Speed Up Proofing

The idea is that once a binsource file is available, having the correct number of octals,
but whether or not containing errors, it should be possible to:

1. Programatically generate image files directly from the binsource files, using
   fonts that closely match the scanned octals, and character positions
   and spacings that closely match the scanned octals.
2. Composite the generated image from the preceding step with 
   the B&W octal images.

The result of such a procedure would be a _new_ image similar to the B&W octal images,
except that at positions where there was a character match there still be octal digits,
but at the positions of _mismatches_ there would be shapes not visually recognizable as
characters.  Depending on the colors used and the method of combining the two images,
these mismatched areas might stand out very dramatically.

Therefore, a visual inspection of the combined images would _very quickly_ identify 
mismatched character positions.  The errors would still need to be corrected, but the
bottleneck of an extremely-long comparison effort, either visual or audio, would be
eliminated, thus greatly cutting the effort involved.

# The Method Adopted by ProoferBox.py

## Rationale

ProoferBox.py creates a "combined image" as described in the preceding section for a 
single page of B&W octals, given the binsource file corresponding to the AGC program.

Because the font used in the AGC assembly-listing printouts does not correspond to any
readily-available modern font (as far as I can tell), ProoferBox.py relies on having a
set of pre-generated PNG files, two for each octal digit (one in B&W just like the B&W page
of octals, and another that is identical, but in red).  The black ones are: 0t.png, 1t.png, ..., and 7t.png,
while the red ones are 0m.png, ..., 7m.png.
When ProoferBox.py generates the combined image, it overlays (with an appropriate 
overlaying method) these octal-digit files onto the original B&W image.

## Preparation of the Individual Octal-Digit Files

Because ProoferBox.py scales the digits appropriately, and because the fonts of 
almost all of the AGC assembly listing printouts are almost identical, I expect that
the octal-digit files only need to be created once, although in principle they could be
prepared separately for every AGC printout.

The digit-preparation process is performed
entirely within GIMP.

1. Load a representative bilevel B&W octal page into GIMP.
2. Change the image type to RGB.
3. Add an alpha-transparency layer if none exists.
4. Use a select-by-color operation to select the entire black area ... i.e., all the 
   octal digits.
5. Invert the selection, so that the entire white background is selected.
6. Delete the background, so that it becomes transparent.
7. For each of the octal characters 0, 1, 2, 3, 4, 5, 6, and 7, find the nicest 
   looking example of that character you can, and use rectangle selection to 
   select a box around that character, in which the black pixels go exactly to the
   boundaries of the box, with no intervening white pixels.  It is helpful in doing
   this to zoom in to 800%, to make sure that no part of the digit is omitted in the
   process.  Then copy the box and paste-as-new to get just the digit in a new
   window, and export the image as 0t.png, 1t.png, or whatever.
8. For each of the octal digits now opened in a individual windows, do a color-select
   of the black, visible portions of the digit, and change the color of that area
   to pure red (#FF0000).  Re-export as 0m.png, 1m.png, etc.

The new octal-digit image files must all be stored in the same folder as ProoferBox.py
itself.

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
pages.  Now, if there are any completely empty memory pages (page = quarter of a bank), 
there won't be a page in the assembly listing for them either, and hence won't be any image file
for that page.  This is handled by having an array, BLANKS[], 
whose entries are 0 for each page which isn't blank, and 1 for each page which is blank.  Typically,
BLANKS[] would simply be an array of 144 entries all equal to 0, but not always; for
RETREAD44, for example, that array looks like this:

	BLANKS=(0 0 0 1  0 0 0 0  0 0 0 0  0 0 0 1  0 0 0 0  0 0 0 0  0 0 1 1  0 0 0 1  0 0 0 1)

And then the actual script is:

        SKIPUNTIL=$FIRSTOUTPAGE; \
	n=$FIRSTOUTPAGE; \
	for i in `seq $((FIRSTOUTPAGE-STARTINGPAGEOFOCTALS)) $((LASTOUTPAGE-STARTINGPAGEOFOCTALS))`
	do   
	  bank=$(( i/4 ))
	  if [[ $bank -lt 4 ]]
	  then
	    bank=$(( bank^2 ))
	  fi
	  pageInBank=$(( i%4 ))
	  if [[ ${BLANKS[$i]} == 0 ]]
	  then
	    if [[ $n -ge $SKIPUNTIL ]]
	    then 
	      pageNum=`printf "%04d" $n`
	      ./ProoferBox.py $BWIMAGEDIR/$pageNum.$EXT $OUTPUTDIR/$pageNum.jpg $bank $pageInBank $PATHTOBINSOURCEFILE
	    fi
	    n=$((n+1))
	  fi
	done

The script above has some problems if any of the entries in BLANKS[] are non-zero, and I've been too lazy
to rewrite it more cleanly.  (The concept of BLANKS[] wasn't originally present, and so the way it's 
implemented is kind of a kludge.)  The problem is that if any of the pages of the program listing are
blank, then more "pages" have to be processed than the loop counter implies, so LASTOUTPUT pages must be
manually incremented (by the number of blank pages) prior to running the script.
