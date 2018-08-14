# Electrical Schematics for the AGC and DSKY

## Introduction

The "schematics" branch of the Virtual AGC repository is devoted to conversion of the electrical schematics of the AGC and DSKY that would otherwise be available (_if_ available, that is) only as scans of 50-year-old printouts into electrical CAD files. We convert these designs so that they are as close as possible to the originals, on the same size "paper", with identical title blocks and borders, with electrical components positioned and sized as close to the original as possible, but with electrical correctness in mind.

Once converted to CAD files, they can then be used for otherwise impossible things like:

- Generating netlists to see what's connected to what.
- Running ERCs (Electrical Rule Checkers) to get a little more assurance of correctness.
- Comparison of different versions of the schematics to see what has changed.
- Attractively and _legibly_ displayed.
- More-easily used as the basis for your own AGC-like or DSKY-like designs.
- Corrected (and _commented_) in those rare instances where the original drawings can be shown to be in error.

## AGC and DSKY Drawings

The currently-available electrical schematics associated with the AGC and DSKY can all be found on [the electro-Mechanical page the main Virtual AGC website](http://www.ibiblio.org/apollo/ElectroMechanical.html).  Each is designated by an 8-digit part number, followed by a single-character revision code (- or A, B, C, ...).  This type of designation is retained for the CAD projects associated with the drawings.

## Sheet Sizes

Almost all AGC and DSKY drawings were on rather huge paper sizes, namely C (22"&times;17" for the really small ones), but more likely D (34"&times;22"), E (44"&times;34"), or J (_X_"&times;34", where _X_ is 55 to 176, for big ones).  We retain those sheet sizes, so unless you have a large plotter, any printouts you make are going to be severely reduced in size.  But don't worry, they'll still be more legible than the original scans, which mostly have come down to us on 11"&times;8.5" paper photocopies anyway.

## CAD System

Electrical schematics will be drawn using the open-source [KiCad](http://kicad-pcb.org/) series of programs.  Specifically, the schematic-editor program in KiCad is called "eeschema", and we'll refer interchangably to "CAD", "KiCad", or "eeschema".  KiCad is an open-source (and free of charge) system for Linux, Mac, or Windows.

Why KiCad?  My guess is that if you are an EE &mdash; and if you aren't, why are you reading this? &mdash; then you probably object to this choice, and would prefer to use your favorite proprietary CAD system, which you happen to have a copy of, or a free-to-download demo copy, and would argue that your professional tool is more efficient, because it lets you get things done quicker and more easily, and probably _better_.  You are absolutely right.  But at the end of the day, this project is devoted to distributing information freely to the public, and we therefore need an open-source program, because that's the only reasonable thing we can to to try and insure that everyone can get the CAD system for free, not just today, but for the foreseeable future as well.  If that puts you off ... sorry!

Besides that, all of KiCad's schematic files, parts libraries, board templates, and so on, are nice, ASCII files.  They can thus not only be store nicely at GitHub, but also processed nicely with scripts, behave well when changes from different people are merged into them, and so on.

Because we retain appearances of the original drawings, as well as the sheet sizes of the original drawings &mdash; and they were plotted on _big_ paper &mdash; we can't really avail ourselves of the standard KiCAD part libraries.  We instead have a _custom_ part library, AGC_DSKY.lib, which you will see in the top-level directory of this branch.  To the extent possible, we'd like to centralize changes to this library, rather than making its maintenance a community effort, so any changes to it should be made with care.  However, because almost no integrated circuits were used in the design of the AGC and DSKY, the library consists almost entirely of things like resistors, capacitors, inductors, diodes, transistors, and so on ... i.e., generic parts, of which there are not a huge number of variations.  So the part library doesn't need the level of maintenance that today's libraries do.

## Community Effort

It is my intention to convert every available scan of an AGC or DSKY electrical drawing (and there are over a hundred of them) to CAD.

If you have the expertise and desire to help out with this, we can certainly accommodate you, though there are presently no procedures in place to do so.

## Basic Procedures for Conversion of a Scanned Schematic

I've converted a handful of these drawings into KiCad now, but it's work in progress.  So while I don't know _everything_ about this, I do know _something_ about how to do it, and that's what I'll try to impart to you in this section.

First, I'll list the basic steps, and they elaborate afterward on any of the steps that have some subtleties involved that can't be explained in just a few words.

1. Clone the "schematics" branch of this repository onto your local system.
2. The existing conversions are in the Schematics/ folder.  Choose the schematic (from amongst the ones that haven't been done yet).  **Hint**: _I'd_ suggest that if there are multiple versions of the circuit, such as different revisions of the same drawing or different drawings representing an evolution of the circuit over time, choose the _earliest_ version.  Then after the early version has been converted, you can probably clone it and modify it quite easily to create all of the later versions in succession.  Or at least, that's my experience.  But you can choose to do it however you want.
3. Let us know that you intend to convert this drawing or this time-sequence of drawings, so that multiple people won't waste their efforts working on the same thing at the same time.
4. Create a new subdirectory under Schematics/ for your drawing.  Name it identically to the drawing as 8 digits plus a one-character revision code.
5. Determine the target sheet-size of the drawing.  The basic size (C, D, E, J) will be marked in the SIZE field of the scanned-drawing's title block.  It's a bit trickier J-size drawings, so I'll describe those issues somewhat below; let's just assume for the moment that you do know the target width, in inches.
6. Process the scanned image of the drawing with an image-editing tool like GIMP or Photoshop.  Personally, I only use GIMP, even though a lot of people consider it funky, because it's free and available on all platforms, so I'm going to pretend that's what's being used, even though any decent image-editing too will probably work just as well.  The object of the processing is to get the image cropped, squared up, and correctly sized.  Again, this is a slightly complex subject so I'll continue discussing it later.
7. To be continued ....

To be continued ....


