Note that the drawing templates, even though matched to drawing paper sizes in our case, don't actually store the page sizes in them.  You have to separately specify the page size elsewhere somehow.  It's easy to select A-size through E-size pages in KiCAD, but it's not so easy to select J-size ones, since you have to call them "custom" pages and manually enter in the sizes. Plus currently, KiCAD doesn't support paper sizes >48" by default, so KiCAD either has to be built from source or else has to be fixed upstream to allow the larger sizes.

Here are all of the sizes for the templates corresponding to existing AGC electrical schematics that I know of:
- C-size (template C4D) &mdash; 17&times;22 inches, 431.8&times;558.8 mm
- D-size (template D8D) &mdash; 22&times;34 inches, 558.8&times;863.6 mm
- E-size (templates E6F, E8H) &mdash; 34&times;44 inches, 863.6&times;1117.6 mm
- J-size (template J12D) &mdash; 80&times;34 inches, 2032&times;863.6 mm
- J-size (template J10D) &mdash; 96&times;34 inches, 2438.4&times;863.6 mm
- J-size (template J8D) &mdash; 100&times;34 inches, 2540&times;863.6 mm
