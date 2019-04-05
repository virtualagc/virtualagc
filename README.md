# Virtual AGC Mechanical Transcriptions

This "mechanical" branch of the Virtual AGC repository is for holding CAD files related to the original Project Apollo designs by the MIT Instrumentation Laboratory for the Apollo Command Module's and Lunar Module's guidance & navigation systems ... or CM and LM G&N system, for short.  Potentially these files are of two types:

* Direct transcriptions of of the original Project Apollo mechanical drawings into DXF format for use with 2D CAD programs.
* 3D models of fabricated parts based on the original Project Apollo drawings into STEP format for use with 3D modeling programs.

At present, there only seems to be interest in the latter.

Contributed .dxf or .step files can be created using any native format and any desired tool, but _only_ .dxf and .step files are accepted for inclusion in this repository; all other native formats are rejected.  

# Naming Conventions

2D files are stored in the 2D-CAD/ folder, while 3D files are stored in the 3D-models/ folder.

Each DXF or STEP file corresponds to a specific original Project Apollo G&N drawing.  Such drawings were conventionally named with a 7-digit number followed by a revision code.  The initial drawing had revision code "-", while subsequent revisions were "A", "B", ..., "Z", "AA", "AB", and so on.  There were no revisions "I" or "O", presumably to avoid confusion with the digits "1" and "0".  For example, drawing 1004713C was revision C, "COVER, TRAY A, AGC COMPUTER", and happened to be used in the Block I AGC model 1003700-011.

Sometimes, there would be multiple different configurations of a given fabricated part or assembly covered in the same drawing. Such differing configurations were designated by a 3-digit "dash number" suffixed to the drawing+revision.  For example, 2003977A-011 is configuration -011 in revision "A" of drawing 2003977, which happens to be the cover for tray A of the Block II AGC model 2003993-031.

In relation to naming of the CAD files, we would expect contributed files to named according to the following system:

> NNNNNNNR[-DDD]-PURPOSE-TITLE

suffixed by .dxf or .step, where

* NNNNNNN is the 7-digit number of the original Project Apollo drawing.
* R is the revision code (- A B ... Z AA AB ...) of the original Project Apollo drawing.
* [-DDD] is the configuration's dash number, if appropriate, or omitted if not.
* PURPOSE is something that expresses the _intent_ of the CAD file.  In most cases, "exact" should be used, to indicate that the purpose is a 100% accurate transcription of the original.  However, for some purposes, such as 3D printing, it may be necessary to modify the design slightly (perhaps to conform to using material with a different strength than originally used), so a different PURPOSE string should be used that conveys what the difference from an exact transcription is.  In general, for contributed models, I would expect an "exact" model to come first, and an altered model to follow that, so I wouldn't expect an altered model to be contributed without an exact model being contributed as well.
* TITLE is preferably taken from the title block of the original Project Apollo drawing, or else is an abbreviated form of it.

It's important to note that if the drawing is revision "-", then the filename will have two consecutive dashes, such as "1004713--exact-TRAY A COVER.step".

# Metadata and Licensing

Each .dxf or .step file can optionally be accompanied by a "readme" file _of the same name_ but suffixed by ".md" rather than ".dxf" or ".step".  The ".md" suffix indicates that the file is in "markdown" format, which is a rich text format (used, for example, by this README.md file you are looking at) to allow headings, bulleted lists, and so on.  However, it can contain plain text without any such flourishes if you prefer.

The .md file should be used to contain any additional information that the developer of the .dxf or .step file wishes to convey, such as:

* Name of the author.
* Extra details about how the model differs from an exact transcription.
* Copyright.
* Licensing.
* etc.

_Preferentially_, the CC0 (Creative Commons "No Rights Reserved") is employed, and if no .md file is submitted with a contributed design, CC0 is assumed.  The CC0 license is equivalent in the United States to what is called the Public Domain, and since no rights are retained, it is incompatible with copyright.  I.e., with the CC0 you don't have any copyright and you should therefore not have any a copyright notice.  Conversely, with other license types you must claim copyright or else you have no right to assign any licensing rights.  We reserve the right to reject any submission with a license we don't like, but CC0 is always acceptable to us.

A separate .md file is used to convey this kind of metadata because attempting to embed such data in file formats that need to be imported or exported by different kinds of software, such as the .step files, tends to cause such data to be discarded.
