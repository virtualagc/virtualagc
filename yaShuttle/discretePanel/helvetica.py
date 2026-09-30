#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Helvetica's vertical metrics, the same wherever the windows are drawn.

The panel, the CAM and the keyboard ask Tk for "Helvetica" and lay their
captions out by what Tk says of it: how tall a line is, how far the letters
rise.  The WIDTHS it reports can be trusted anywhere, because every stand-in
for Helvetica -- Nimbus Sans on Linux, Arial on Windows -- copies its advance
widths exactly.  The HEIGHTS cannot.  Measured at the same size, 10 points at
2.67 pixels a point:

                    ascent   descent   line
    Nimbus Sans       20        8       28      (Linux, where these were drawn)
    Arial             25        7       32      (Windows)

Arial's letters are the same letters at the same size; it only claims more
room above them.  But the panel stacks some forty rows by the line height, so
on Windows it came out an eighth taller than its window and lost its bottom
edge -- the HALT legend and the mass-memory lamps -- and every caption sat
about three pixels low, since Tk centres the box it believes in and not the
ink.

So on Windows the three programs take their metrics from here instead:

    ascent(font), descent(font), linespace(font)
        what Nimbus Sans reports at that size -- 0.729 and 0.271 of the em,
        each rounded up, which reproduces every figure measured on Linux from
        6 to 40 points
    lift(font, anchor)
        how many pixels higher to draw a caption so that its ink lands where
        Nimbus Sans would have put it, given Tk's anchor

Everywhere else these are Tk's own figures and a lift of nothing, so Linux
and macOS draw exactly as they did.
"""

import math
import sys

FAKE = sys.platform == "win32"
ASCENT_EM, DESCENT_EM = 0.729, 0.271

_cache = {}


def _both(font):
    """((real ascent, real descent), (reference ascent, reference descent))."""
    key = str(font)
    # The cache is by the font's name, and a named font can be resized, so
    # the size is part of what is remembered.
    size = font.cget("size")
    hit = _cache.get(key)
    if hit is not None and hit[0] == size:
        return hit[1]
    real = (int(font.metrics("ascent")), int(font.metrics("descent")))
    if size < 0:
        em = float(-size)                       # a size in pixels
    else:
        # Points to pixels: what Tk's scaling says a point is.
        import tkinter
        em = size * float(tkinter._get_default_root().winfo_fpixels("1p"))
    ref = (int(math.ceil(ASCENT_EM * em - 1e-6)), int(math.ceil(DESCENT_EM * em - 1e-6)))
    _cache[key] = (size, (real, ref))
    return real, ref


def ascent(font):
    if not FAKE:
        return int(font.metrics("ascent"))
    return _both(font)[1][0]


def descent(font):
    if not FAKE:
        return int(font.metrics("descent"))
    return _both(font)[1][1]


def linespace(font):
    if not FAKE:
        return int(font.metrics("linespace"))
    ref = _both(font)[1]
    return ref[0] + ref[1]


def lift(font, anchor="c"):
    """Pixels to take off a caption's y so its baseline is where the
    reference font's would be.  One line of text; Tk's anchor as given to
    create_text."""
    if not FAKE:
        return 0.0
    (ra, rd), (fa, fd) = _both(font)
    a = str(anchor).lower()
    if a.startswith("n"):
        return float(ra - fa)           # hung from the top: the top is higher
    if a.startswith("s"):
        return float(fd - rd)           # stood on the bottom
    return ((ra - rd) - (fa - fd)) / 2.0
