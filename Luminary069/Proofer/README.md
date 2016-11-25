Right now these are just some notes on some documentation I _might_ prepare at some point
if this works out okay.

# Introduction

The program Proofer.py is a tool that I hope will greatly speed up proofing of octal 
(binsource) files, inspired by the great speed-ups in data-entry that octopus.py has
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
but with or without the correct bank checksums, it should be possible to:

1. Programatically generate image files directly from the binsource files, using
   fonts that closely match the scanned octals, and character positions
   and spacings that closely match the scanned octals.
2. Subtract or similarly combine the generated image from the preceding step with 
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

# The Method Adopted by Proofer.py

## Rationale

The Proofer.py script is a Python program, actually [Python with Wand](http://docs.wand-py.org),
which creates an [ImageMagick](http://www.imagemagick.org) for the Python language.

Beware of the ghastly 
tendency of some Linux distributions (if you're using Linux) to install GraphicsMagick
in place of ImageMagick, whilst pretending that ImageMagick is what has been installed.
I don't know of any of this works with GraphicsMagick, and don't care.

Proofer.py creates a "combined image" as described in the preceding section for a 
single page of B&W octals, given the binsource file corresponding to the AGC program.

Because the font used in the AGC assembly-listing printouts does not correspond to any
readily-available modern font (as far as I can tell), Proofer.py relies on having a
set of pre-generated PNG files, one for each octal digit: 0.png, 1.png, ..., 7.png.
When Proofer.py generates the combined image, it overlays (with an appropriate 
overlaying method) these octal-digit files onto the original B&W image.

## Preparation of the Individual Octal-Digit Files

Because the image resolutions may differ from one AGC assembly-listing to the next,
I suppose, the octal-digit files may need to be prepared anew, as a one-time step,
for each AGC program being processed.  The digit-preparation process is performed
entirely within GIMP.

1. Load a representative bilevel B&W octal page into GIMP.
2. Change the image type to RGB.
3. Add an alpha-transparency layer if none exists.
4. Use a select-by-color operation to select the entire black area ... i.e., all the 
   octal digits.
5. Color the entire selected area pure green (#00FF00).
6. Invert the selection, so that the entire white background is selected.
7. Delete the background, so that it becomes transparent.
8. Determine a representative box size into which octal digits in the image can all
   fit, but in which there is no overlapping of boxes between adjacent characters.
   For example, for Luminary069, I chose 22x30 pixels.
9. For each of the octal characters 0, 1, 2, 3, 4, 5, 6, and 7, find the nicest 
   looking example of that character you can, and use rectangle selection to 
   select a box around that character which is the uniform size from the preceding
   step.  You want the character to be centered in the box, but this won't be 
   exactly possible in most cases, so just keep in mind that you want the characters
   to be centered consistently, so that if drawn side-by-side they wouldn't look
   oddly aligned.  Copy and paste as new.  In other words, a new image that's the
   the size of the standard box will be created, containing just that character.
   Export the new image with the appropriate name (0.png, 1.png, etc.).

The new octal-digit image files should all be stored in the same folder as Proofer.py
itself.

