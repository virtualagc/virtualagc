#Virtual AGC Project Electrical Schematics for AGC/DSKY

This branch is based on the speculative notion that all of the electrical schematics of the AGC and DSKY that we've collected scans for will be converted into machine readable schematic files that can be used to actually generate netlists, verify connectivity, create actual readable diagrams (rather than old smudgy ones), and so forth, or can be used as something people can try to fork off their own designs from.  Right now this is just a whim, but I intend to produce at least a few simple files for it and need some place to store them.

Electrical schematics will be drawing using the open-source KiCAD series of programs.  All of the schematic files, parts libraries, board templates, and so on, used by KiCAD are nice, ASCII files, and so can thus be stored nicely in GIT.

Electrical schematics are all designated by an 8-digit number, which is the part number, followed by a single-leter revision code (- or A, B, C, ...), and that designation is retained as the filename of any given schematic.

Rather than use the standard KiCAD part libraries, a custom part library is used instead, and it is contained here in this repository.

More to come later, presumably ....
