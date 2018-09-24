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

- AGC_DSKY.lib &mdash; contains the handful of generic parts needed: resistor, capacitor, diode, ..., in general, everything other than NOR gates.
- D3NOR-_VIN_-_GND_[-expander].lib &mdash; a variety of libaries that handle the wild profusion of NOR-gate symbols needed for the schematics.

You will see these in the top-level directory of this branch.  To the extent possible, we'd like to manage changes to these libraries ourselves, rather than making their maintenance a community effort.

## Installation of KiCad

- It's best to use the nightly build of KiCad (presently v6) rather than a stable version of it (presently v4 or v5), to stay as up-to-date as possible with respect to the bug reports we file.
- KiCad global library setup: Use the main-menu function Preferences/ManageSymbolLibraries.  Select the Global Libraries tab in the window that appears.  Use the folder icon to add all of the .lib files contained in the folder to which you've cloned this repository.
- Eeschema global preferences: In KiCad, open any existing project, or create a new one, and view it in the schematic editor.  Use the main-menu function Preferences/Preferences. In the window that opens up, select Eeschma and change measurement units to inches, default text size to 140.  Select Display Options and change grid size to 25 mils, line thickness to 20 mils.

## Community Effort

It is my intention to convert every available scan of an AGC or DSKY electrical drawing (and there are over a hundred of them) to CAD.

If you have the expertise and desire to help out with this, we can certainly accommodate you, though there are presently no procedures in place to do so.

[The basic steps of transcribing a scanned AGC/DSKY schematic into KiCad are discussed at the main Virtual AGC website.](http://www.ibiblio.org/apollo/ElectroMechanical.html#Appendix:_KiCad_for_Virtual_AGC)
