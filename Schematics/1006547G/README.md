This folder contains the transcription of the original Apollo Program drawing 1006547G to KiCad.  This is the electrical schematic for Block I AGC module A33/A34.  We also have revisions 1006547- through 1006547F of the drawing.  1006547- is significantly electrically different from the others.

_Prior_ to the availability of the original schematic drawings for module A33/A34, the schematics for this module were "recovered" from AC Electronics document ND-1021041 as a different set of KiCad files, referred to as [1006547r](https://github.com/virtualagc/virtualagc/edit/schematics/Schematics/1006547r).  Now that both are available, it is a useful proofing method, as well as a way to judge the accuracy of ND-1021041, to compare the netlists of these two implementation of 1006547 in CAD.  There is [a Python script](https://github.com/virtualagc/virtualagc/edit/schematics/Scripts/netlistCompare.py) to assist in carrying out this comparison.

Various factors need to be ignored in the comparison:
* Different reference designators for NOR gates
* Different input-pin assignments in NOR gates
* Different naming of backplane signals, in cases where ND-1021041 _does not_ provide explicits name for them.

Differences which can be detected using this method, once the factors above are discounted, are:
* Different naming of backplane signals, in cases where ND-1021041 _does_ provide explicit names for them.
* Different connectivity.

The differences that are detected are then either transcription errors (which are fixed within the CAD files themselves), legitimate differences in conventions, or else unexplainable differences.  The findings relating to unexplainable differences are noted below.

_Connector pin 61._  The backplane signals associated with this pin seem to have changed over time:

|Drawing   |Module A33  |Module A34  |
|----------|------------|------------|
|1006547-  |(left blank)|(left blank)|
|1006547A  |Q2X/        |F12A/       |
|1006547B  |Q2X/        |F12A/       |
|1006547C  |Q2X/        |F12A/       |
|1006547D  |Q2X/        |F12A/       |
|1006547E  |N.C.        |F12A/       |
|1006547F  |N.C.        |F12A/       |
|1006547G  |MNHSBF      |F12A/       |
|ND-1021041|B2/         |0VDC        |

* For connector pin 61, 1006547G indicates backplane signals MNHSBF (module A33) and F12A/ (A34), while ND-1021041 indicates B2/ and 0VDC respectively.
