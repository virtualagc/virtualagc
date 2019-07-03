This folder contains two separate but related KiCad projects.

* original.pro (original.sch + 2005938C-p1of2.sch + 2005938C-p2of2.sh) is intended to be a visually accurate representation of the original Apollo Program drawing, but is not electrically valid in KiCad (or, I imagine, anywhere else)
* module.pro (module.sch + A.sch + B.sch + C.sch + BOM.sch) is intended to be an electrically accurate and valid representation of the original circuit, but does not conform too closely visually to the original drawing.

The reason behind this is that the original drawing provided a drawing of a subcircuit that was supposed to be replicated 8 times, along with a large table describing how the subcircuits were interconnected, without providing any wires (or equivalent constructs like net-labels or ports) to do so.  Consequently, it was not possible to make a single transcription of the design that it both visually and electrically accurate, or in the latter case, valid.
