# Electrical Schematics for the AGC and DSKY

## Introduction

The "schematics" branch of the Virtual AGC repository is devoted to conversion of the original hardcopies of AGC and DSKY electrical schematics into electrical CAD files. We convert these designs so that they are as close as possible to the originals, on the same size sheets, with identical title blocks and borders, with electrical components positioned and sized as close to the original as possible, but with electrical correctness in mind.

Once converted to CAD files, they can then be used for otherwise impossible things like:

- Generating netlists to see what's connected to what.
- Running ERCs (Electrical Rule Checkers) to get a little more assurance of correctness.
- Comparison of different versions of the schematics to see what has changed.
- Attractively and legibly displayed, at least in comparison to the original scans.
- More-easily used as the basis for your own AGC-like or DSKY-like designs, such as creation of circuit boards.
- Corrected (and commented) in those rare instances where the original drawings can be shown to be in error.
- Translated to Verilog.
- Used for simulation of the hardware.

## AGC and DSKY Drawings

The currently-available scans of electrical schematics associated with the AGC and DSKY can all be found on [the electro-Mechanical page the main Virtual AGC website](http://www.ibiblio.org/apollo/ElectroMechanical.html).  Each is designated by an 8-digit part number, followed by a single-character revision code (- or A, B, C, ...).  This type of designation is retained for the CAD projects associated with the drawings.

## CAD System

Electrical schematics are drawn using the open-source [KiCad](http://kicad-pcb.org/) series of programs.  Specifically, the schematic-editor program in KiCad is called "eeschema", and we'll refer interchangably to "CAD", "KiCad", or "eeschema".  KiCad is an open-source (and free of charge) system for Linux, Mac, or Windows.

Why KiCad?  My guess is that if you are an EE &mdash; and if you aren't, why are you reading this? &mdash; then you probably object to this choice, and would prefer to use your favorite proprietary CAD system, which you happen to have a copy of, or a free-to-download demo copy, and would argue that your professional tool is more efficient, because it lets you get things done quicker and more easily, and probably _much better_.  You are absolutely right.  But at the end of the day, this project is devoted to distributing information freely to the public, and we therefore need an open-source program, because that's the only reasonable thing we can do to try and insure that everyone can get the CAD system for free, not just today, but for the foreseeable future as well.  If that puts you off ... sorry!

Besides that, all of KiCad's schematic files, parts libraries, board templates, and so on, are nice, ASCII files.  They can thus not only be stored nicely at GitHub, but also processed nicely with scripts, behave well when changes from different people are merged into them, and so on.

Because we retain appearances of the original drawings, as well as the sheet sizes of the original drawings &mdash; they were plotted on very big paper &mdash; we can't really avail ourselves of the standard KiCAD part libraries.  We instead have our own custom part libraries:

- AGC_DSKY.lib &mdash; contains the handful of generic parts needed: resistor, capacitor, diode, ..., in general, everything other than NOR gates.  The only tricky components are the connectors; there is a script, Script/MakeConnector.py, that can be used to create variations of the basic connector type, which can then be imported into AGC_DSKY.lib
- D3NOR-_VIN_-_GND_[-expander][-nopinnums].lib &mdash; a variety of libaries that handle the wild profusion of NOR-gate symbols needed for the schematics.  These libraries differ in the net they use for powering the NORs (namely _VIN_), the net they use for grounding the NORs' unused inputs and power supply (namely _GND_), and in whether the library contains "normal" NOR gates vs "expander" NOR gates.  Also, on most of the drawings the pin numbering is shown, but on early drawings they are not.  _VIN_ seems to always be either +4VDC, +4SW, +4SW2, FAP, or NC ("no connect"), while _GND_ is one of 0VDCA, 0VDC, or 0VDC2, so you can see that there are 5&times;3&times;2&times;2=60 overall possibilities; fortunately, _only_ about 16 of them are actually used.  :-)  There is a script, Script/MakeDualNorLib.py, that produces these libaries, given the basic parameters (_VIN_ etc.) just mentioned.

You will see these in the top-level directory of this branch.  To the extent possible, we'd like to manage changes to these libraries ourselves, rather than making their maintenance a community effort.

## Installation of KiCad

- It's best to use the nightly build of KiCad (presently v6) rather than a stable version of it (presently v4 or v5), to stay as up-to-date as possible with respect to the bug reports we file.
- KiCad global library setup: Use the main-menu function Preferences/ManageSymbolLibraries.  Select the Global Libraries tab in the window that appears.  Use the folder icon to add all of the .lib files contained in the folder to which you've cloned this repository.
- Eeschema global preferences: In KiCad, open any existing project, or create a new one, and view it in the schematic editor.  Use the main-menu function Preferences/Preferences. In the window that opens up, select Eeschma and change measurement units to inches, default text size to 140.  Select Display Options and change grid size to 25 mils, line thickness to 20 mils.

## Printing from KiCad

Printing out one of the CAD files, either to a physical printer or to an image format such as PNG or PDF, is currently somewhat trickier than it needs to be.  The basic problem is that these drawings have a much larger sheet size than KiCad has been accustomed to handle in the past, and KiCad is only slowly making the changes we need to handle this difference.  Recall, we are trying to preserve legacy drawings rather than designing new ones, so we need KiCad to accomodate us rather than adapting ourself to KiCad's limitations.  Fortunately, it has worked out pretty well so fare ... but not 100% perfectly.

Two issues presently complicate printing:

1. For dashed lines, KiCad choses its own pitch for the dashes rather than allowing us to choose it, and since KiCad's chosen pitch is only appropriate for much smaller sheet sizes, we end up with dashed lines that basically look solid.
2. For sheet sizes above a certain point, KiCad's print feature simply embeds incorrect metadata into its output files regarding the sheet size ... in fact, it makes them only a tenth the size they ought to be.

The best way I've found to get around this is to use the following basic procedure for printing:

- Use KiCad's "plot" feature rather than its "print" feature.  Plot to an output file in Postscript format.  Make sure the default line size used is 20 mils.
- Edit the Postscript file (which is just a text file) to change the styling of all dashed lines to an acceptable pitch.  What this actually involves is finding all strings of the form "[_NUMBERS_ _NUMBERS_] 0 setdash" and changing them to "[1000 1000] 0 setdash".
- Convert the Postscript to PNG using some program like GIMP, ImageMagick, or Photoshop.  The important factors, assuming you have control over them are: white background (as opposed to transparent), density units should be pixels per inch, the density should be 150 (pixels per inch), the images should be rotated to landscape.
- You can then, of course, print the PNG, convert it to PDF, or whatever pleases you.  My experience is that even the largest of the AGC drawings can be printed to 11"&times;17" and remain readable, though just barely.

The script Scripts/printKiCad.sh carries out the two middle steps (edit the dashed-line styling and convert Postscript to PNG), though it's only for Linux.  If someone wants to create comparable scripts for Mac OS X or for Windows, feel free to send it to me.  The script uses 'sed' and ImageMagick, both of which are available for both Mac OS X and Windows.

## Conventions Used in the Drawings

The original designers used various conventions and I've used various conventions in dealing with their conventions, and you may need to be aware of all of them for a full grasp of how to work with the drawings.

### Project Naming

Each of the CAD designs corresponding to one of the original drawings has a sub-directory in the Schematics/ folder, named identically to the original drawing. For example, for original drawing 2005259A (module A1), we have the folder Schematics/2005259A/.

Within that project folder, the KiCad project file is always named module.pro. Logic modules like 2005259A were implemented as pairs of circuit boards, and sometimes it is useful to have KiCad projects for the individual boards rather than for the module as a whole.  In such cases, you may find additional KiCad project files with names like board1.pro or board2.pro in the project folder as well, though at this point that has not been done for most modules.

### Organization of Drawings into Sheets

Many of the CAD designs, particularly for the "logic flow diagrams" for AGC modules A1-A24, are organized almost exactly like the original physical drawings were.  Basically, the original drawings for those modules were organized into completely electrically-independent sheets (usually 2, but occasionally 1 or 3).

In KiCad, the way to organize such a design is to create a top-level schematic that contains just 2 (or 1 or 3) blocks representing the individual sheets, plus a few wires interconnecting those blocks.  For the logic modules, A1-A24, only ground and power nets are common between the individual sheets, and hence only a few signals with names like 0VDCA or +4VDC interconnect the sheets on the top-level schematic.

### Organization of Drawings into Reusable Blocks

For modules of a more analog nature, or used for interfacing, such as AGC modules A25-A31 and B1-B17, another commonly-experienced situation is that in which the top-level drawing uses a lot of small circuit blocks that are iterated repeatedly throughout the top-level schematic. 

The overall design thus consists of a complex-looking top-level schematic, on which a number of the "components" are really circuit blocks that are themselves represented by separate schematics.  In general, each of those circuit blocks is implemented as a separate CAD sheet that acts as a template, and for each appearance of the block in the top-level schematic, the system uses the same template schematic for the circuit block but assigns different reference designators and netnames to each instance.  These CAD sheets for the circuit-block templates won't correspond exactly to a sheet of the original drawing, but will usually be just part of such an original sheet.

For example, in this case, an original drawing that consisted of two sheets, one of which defined the top-level design, and one of which might have defined the templates for (say) 5 circuit blocks called A, B, C, D, and E, will in the CAD design become 6 sheets, one for the top-level design and one for each of the A, B, C, D, and E circuit blocks.  Nevertheless, we still try to maintain as much of the visual appearances of each of these as possible, as compared to the original drawing, so that the correctness and significance of the CAD transcription is as clear as possible.

Preservation of hierarchical reference designators is important when working with the physical AGC circuit modules, because they have reference designators marked on them. What should the reference designators in the circuit blocks be like?  Note first that when a circuit-block appears in the top-level schematic, it is assigned a "sheet name".  For a circuit block with template C.sch, for example, those sheet names would be 1C, 2C, 3C, and so forth on the top-level schematic.  Similarly, circuit block B.sch would have sheet names 1B, 2B, etc.  These designations were drawn on the original top-level sheets, and we continue to use them as-is.  Now suppose that the components in template C.sch are R1, R2, ..., C1, C2, ....  For a particular _instance_ of C.sch appearing in the top-level schematic (say, instance sheet 3C), these reference designators become 3R1, 3R2, ..., 3C1, 3C2, ....  (You may wonder how that could work, since for example, if instance 2B of block B and 2C of block C both had an R1, then the reference designators for both would become 2R2.  The original designers took care so that there was no overlap in the reference designators in the templates for blocks A, B, C, D, and E.  Therefore, the hypothetical situation just mentioned doesn't occur.)

KiCad's schematic editor deals with this configuration well, except for the fact that the naming convention for the reference designators just mentioned is not one that its Tools/AnnotateSchematics function can apply automatically for itself.  Therefore, we will eventually have to create a script (but don't have one yet!) that can apply this reference-designator naming for us.  Until that happens, we just have to let KiCad's Tools/AnnotateSchematics function apply some reference-designator reassignment for us and live with it.

### NOR Gates

TBD

### Connectors

TBD

## Community Effort

It is my intention to convert every available scan of an AGC or DSKY electrical drawing (and there are over a hundred of them) to CAD. I've gotten this down to a science, so to maintain aesthetic and electrical consistency it's perhaps best that I continue that as an individual effort.  If I die or something, feel free to jump in and finish it up!

Where help _would_ be appreciated is in proof-reading the transcribed CAD files vs the scans of the original drawings.  If you would care to assist, please contact me.
