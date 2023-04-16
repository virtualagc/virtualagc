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
complete, I checked it with ProoferComments.py and immediately found and corrected 38 more errors in
that way.  It so happens that the P40-47 log section has 34 pages, so what I had found (and corrected
with the assistance of ProoferComments.py) more than 1 additional error per page, in spite of my best efforts
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
Because ProoferComments.py scales the characters appropriately to the bounding boxes, and because the fonts of 
almost all of the AGC assembly listing printouts are almost identical, I expect that
the octal-digit files only need to be created once, although in principle they could be
prepared separately for every AGC printout.

## Theory of Operation

ProoferComments.py uses the [Tesseract OCR engine](https://github.com/tesseract-ocr), but not
for OCR'ing, and no "training" of the engine has been performed.  Rather, Tesseract's ability to create
"bounding boxes" for all of the characters in the bi-level B&W image produced by octopus.py, and to output that data in
machine readable form, is used.

The bounding boxes found by Tesseract (in a properly-cropped high-quality B&W image) are in 1-to-1 correspondence
with the characters in the code comments in the AGC source code.  What
ProoferComments.py does, basically, is to position the matchN.png and nomatchN.png files mentioned in the
preceding section into the bounding boxes, using just comment characters and ignoring all of the source code
that isn't a comment, scaling them appropriately.  

ProoferComments.py also provides a couple of supplementary services which are helpful in diagnosing certain
kinds of errors:

* It filters out bounding boxes that have an unusual size or shape, treating them as noise and not trying
  to fit comment-characters into them.  This may not be necessary as octopus.py continues to mature and
  improve, though it is helpful if non-comment material is cropped from the imagery using a program such
  as GIMP or Photoshop.
* Sometimes the amount of noise is great enough, even with the noise filtering mentioned above, that
  Tesseract's bounding boxes cannot be matched 1-to-1 with comment characters.  Specifically, there may
  be too many or two few bounding boxes for the number of comment characters.  ProoferComments.py marks
  this condition visually in a distinctive way.

# Requirements for ProoferComments.py

* Python 2.5
* [Wand 0.4.4](http://docs.wand-py.org)
* [ImageMagick](http://www.imagemagick.org)
* [Tesseract OCR engine](https://github.com/tesseract-ocr), including the default English-language dataset.

Beware of the ghastly 
tendency of some Linux distributions (if you're using Linux) to install GraphicsMagick
in place of ImageMagick, whilst pretending that ImageMagick is what has been installed.
I don't know of any of this works with GraphicsMagick, and don't care.

**Note:** You may notice a folder called fontAGC/.  While this folder does indeed contain a TrueType font created from the characters 
as printed in AGC assembly listings, that font is not used in any way by this software, and needn't be installed
on your system.

# Usage of ProoferComments.py

ProoferComments.py requires the files match0.png-match127.png and nomatch0.png-nomatch127.png font-image files described earlier.  Not all the files need be present, since not all 7-bit ASCII characters appear in AGC printouts.  The files match127.png and nomatch127.png (typically, solid rectangular blocks) are used in case a character for a missing file is encountered.

These font images must reside in the asciiFont/ folder, which must be present in the same folder as ProoferComments.py itself. You must 'cd' to the folder containing ProoferComments.py before running it, or the font images won't be found.  However,
input and output files for it can reside an any other folder.

     ./ProoferComments.py BWINPUTIMAGE OUTPUTIMAGE PAGENUMBER AGCSOURCEFILE \[SCALE \[NODASHES \[PSM\]\]\]

The command-line parameters are:

* `BWINPUTIMAGE` is the pathname to a bi-level B&W AGC assembly-listing page image, with all 
   non-comment characters removed, as prepared by octopus.py.
* `OUTPUTIMAGE` is the pathname to where the composite image for proofing will be written.
* `PAGENUMBER` is the page number of the AGC assembly-listing being processed, as indicated
  by comments in the source code of the form "## Page `PAGENUMBER`".
* `AGCSOURCEFILE` is the source-code file (\*.agc) in which the `PAGENUMBER` resides.
* `SCALE` (optional, default 1.0) is a multiplier for the resolution (DPI) of the `BWINPUTIMAGE`.
  It is relative to the scale of the archive.org Sunburst 120 images, which are nominally 3050 
  pixels high.  In fact, not all of the pages in any given set of images are necessarily the 
  exact same size, so the `SCALE` value used may need to be fiddled with somewhat.  For example,
  for Aurora 12, I used the value `SCALE` = 1.15.
* `NODASHES` (optional, default 0) is used to instruct ProoferComments that Tesseract is going to
  ignore lines consisting entirely of spaces and dashes, or spaces and underlines. I'm not sure
  the conditions under which Tesseract does this, but I tend to always use 1 for this value, and
  think the default value of 0 is probably inappropriate.
* `PSM` (optional, default 6) is a parameter passed directly to Tesseract during bounding-box 
  generation.  The only useful values are 6 and 4.  6 is safer.  The reason that one might wish 
  to use `PSM` = 4 on an isolated page is that in generating bounding boxes, Tesseract sometimes
  (though rarely) simply decides to ignore words or even entire lines.  Since `PSM` 6 and 4 tend
  to do this at _different_ times and places, you can often fix such an error by reprocessing the
  page with 4.

# Markings in the Proofing Images Output by ProoferComments.py

Ideally, there is a 1-to-1 match between the number of bounding boxes found by Tesseract in the B&W image
and the number of comment characters in the source code.  In this case, the proofing image looks like
the B&W image, except that

1. Characters that _match_ (i.e., where the source-code transcription was _correct_) may have a 
   barely-noticeable green or red fringe 
   around them.  The color is not significant: if red, it merely means that Tesseract guessed the character
   wrong, while if green it means that Tesseract guessed the character correctly ... we couldn't care
   less what Tesseract guessed, so it doesn't matter what color it was.
2. Characters that _don't match_ (i.e, where the source-code transcription was _wrong_) won't look like
   characters at all.  They'll look like two characters superimposed (the correct one and the incorrect one),
   one in black, and the other in green or red.

If there's noise which ProoferComments.py's noise filter has been able to detect, the proofing image will
usually look very much like what's described above, except that additionally, the noise specks which have
been filtered out will have magenta boxes drawn around them to call attention to them.  They can 
be ignored if the proofing image is otherwise normal, but are useful if the image is not normal and you
need to determine why.

There are really two cases:  that of there being extra bounding boxes in a row (relative to the number of comment characters), and that of there being too few.

If there are _extra_ bounding boxes on a line, they are displayed much like the noise-boxes mentioned above,
except that they are in orange rather than magenta.

Conversely, if there are _too few_ bounding boxes on a line, a horizontal orange line is drawn after the last
bounding box, to the edge of the page.  If we've completely run out of bounding boxes, not just on a line
but on the entire page, the orange line is vertical instead, from the bottom of the final bounding box to 
the bottom of the page.


