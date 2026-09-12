#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of the Space Shuttle GPC STATUS / FAILED GPC matrix.

A 5×5 array of square indicator lamps with the diagonal absent: rows are
the voting GPC, columns the failed GPC.  Digits 1-5 typed as a pair
(row, then column) toggle that lamp.  There is no visible entry widget.
Clicking a lamp toggles it too.  Diagonal cells show a yellow GPC number
instead of a lamp.

The layout follows ~/Desktop/voting2.png (the clearest CAM drawing):
dimension-ruled GPC STATUS / FAILED GPC with the titles sitting right of
centre, a rounded bezel, large yellow GPC numbers on the diagonal, and a
small mesh lamp in the upper half of each off-diagonal cell.  (Y) and (W)
in the drawing are colours, not text.

Styling follows panelO6.py: gull-grey panel, Helvetica legends, a
standard decorated resizable window.  Unlike panelO6.py / stsKeyboard.py
this window *does* take the keyboard, because the lamps are driven by
keystrokes.

Usage:
    python3 voting.py
    python3 voting.py --size 512
    python3 voting.py --geometry 560x600+80+20
"""

import argparse
import os
import tkinter as tk
import tkinter.font as tkfont

N = 5

# Same gull grey as panelO6.py.
C_WINDOW = "#2a2a2a"
C_PANEL = "#c6c3b6"
C_PANEL_HI = "#dddaca"
C_PANEL_LO = "#8e8b7e"
C_INK = "#1b1b1b"
C_LAMP_ON = "#ffffff"
# Slightly darker than the pane, so an unlit lamp is a square you can
# still see without competing with a lit one.
C_LAMP_OFF = "#a4a193"
C_DIAG = "#d4aa00"     # yellow GPC identity on the diagonal

MARGIN = 28
CELL = 76
# voting2.png: tight gaps, a small mesh lamp (~1/4 of the cell) in the
# upper half of each off-diagonal cell.
GAP = 5
GRID_PAD = 10          # air between the rounded bezel and the cells
RADIUS = 16
LAMP_FRAC = 0.26       # inner lamp side / cell side
LAMP_GRID = 4          # 4×4 mesh, as in voting2.png
FULL_SIZE = 768        # --size units: 768 is the design window, as in panelO6.py

# Left of the grid: stacked "VOTING GPC", a bracket, then the row numbers.
VTEXT_X = 42
BRACKET_X = 58
ROW_NUM_X = 78
GRID_X0 = 102
GRID_SPAN = N * CELL + (N - 1) * GAP
BEZEL_X0 = GRID_X0 - GRID_PAD
BEZEL_X1 = GRID_X0 + GRID_SPAN + GRID_PAD
REF_W = int(BEZEL_X1 + MARGIN)


def log(msg):
    print("voting: %s" % msg, flush=True)


def scaled_wh(w, h, size):
    """Pixel size at --size N, where FULL_SIZE (768) is the design window."""
    f = size / float(FULL_SIZE)
    return max(1, int(round(w * f))), max(1, int(round(h * f)))


class VotingPanel:
    def __init__(self, root, size=FULL_SIZE):
        self.root = root
        root.title("GPC STATUS")
        root.configure(bg=C_WINDOW)
        self.size = size

        # Lamps[row][col] is True when ON.  The diagonal is never a lamp.
        self.lamps = [[False] * N for _ in range(N)]
        self._pending = None       # first digit of a pair, 1-5, or None
        self._hits = []            # (row, col, x1, y1, x2, y2) in canvas px
        self._wh = (0, 0)
        self._font_cache = {}
        self._cursor_hits = False
        self.s = 1.0
        self.ox = 0.0
        self.oy = 0.0
        self.L = {}
        self.REF_H = 600           # replaced by _layout() on first redraw

        mw, mh = scaled_wh(320, 340, size)
        root.minsize(mw, mh)

        cw, ch = scaled_wh(REF_W, self.REF_H, size)
        self.cv = tk.Canvas(root, bg=C_WINDOW, highlightthickness=0,
                            width=cw, height=ch)
        self.cv.pack(fill="both", expand=True)
        self.cv.bind("<Configure>", self._on_configure)
        self.cv.bind("<ButtonPress-1>", self._on_press)
        self.cv.bind("<Motion>", self._on_motion)
        self.cv.bind("<Leave>", lambda _e: self.cv.configure(cursor=""))
        # Invisible keystrokes: no Entry, just the digits 1-5.
        root.bind("<Key>", self._on_key)
        self.cv.bind("<Key>", self._on_key)
        root.after_idle(lambda: self.cv.focus_set())

        self._dump_state("startup")

    # ---- fonts / scale --------------------------------------------------

    def _tkfont(self, size, bold=True):
        pts = max(1, int(round(size * self.s)))
        key = (pts, bold)
        font = self._font_cache.get(key)
        if font is None:
            font = tkfont.Font(family="Helvetica", size=pts,
                               weight="bold" if bold else "normal")
            self._font_cache[key] = font
        return font

    def _font(self, size, bold=True):
        pts = max(1, int(round(size * self.s)))
        return ("Helvetica", pts, "bold" if bold else "normal")

    def _th(self, size):
        """Half-height of a centre-anchored caption, in reference coords."""
        ls = float(self._tkfont(size).metrics("linespace"))
        return 0.5 * ls / max(self.s, 0.01)

    def _on_configure(self, event):
        if event.widget is not self.cv:
            return
        if (event.width, event.height) == self._wh:
            return
        if event.width < 40 or event.height < 40:
            return
        self._wh = (event.width, event.height)
        self.redraw()

    def _scale(self):
        cw = max(self.cv.winfo_width(), 40)
        ch = max(self.cv.winfo_height(), 40)
        self.s = min(cw / float(REF_W), ch / float(self.REF_H))
        self.ox = (cw - REF_W * self.s) / 2.0
        self.oy = (ch - self.REF_H * self.s) / 2.0

    def X(self, x):
        return self.ox + x * self.s

    def Y(self, y):
        return self.oy + y * self.s

    def xy(self, x, y):
        return (self.X(x), self.Y(y))

    # ---- primitives -----------------------------------------------------

    def _line(self, x1, y1, x2, y2, **kw):
        self.cv.create_line(self.X(x1), self.Y(y1), self.X(x2), self.Y(y2),
                            **kw)

    def _text(self, x, y, text, size=11, fill=C_INK, bold=True, anchor="c"):
        self.cv.create_text(self.X(x), self.Y(y), text=text, fill=fill,
                            font=self._font(size, bold), anchor=anchor)

    def _vtext_span(self, x, y1, y2, text, size=10, fill=C_INK):
        """Stacked caption whose letters are spaced evenly between y1 and y2.

        Spaces are kept as empty slots so 'VOTING GPC' reads as two words.
        """
        chars = list(text)
        n = len(chars) or 1
        step = (y2 - y1) / float(n)
        for i, ch in enumerate(chars):
            if ch.isspace():
                continue
            self._text(x, y1 + step * (i + 0.5), ch, size=size, fill=fill)

    def _rect(self, x1, y1, x2, y2, **kw):
        return self.cv.create_rectangle(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

    def _oval(self, x1, y1, x2, y2, **kw):
        return self.cv.create_oval(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

    def _poly(self, pts, **kw):
        flat = []
        for x, y in pts:
            flat.extend(self.xy(x, y))
        return self.cv.create_polygon(flat, **kw)

    def _round_rect(self, x1, y1, x2, y2, r, fill="", outline=C_INK, width=2):
        """Axis-aligned rounded rectangle in reference coords."""
        X1, Y1, X2, Y2 = self.X(x1), self.Y(y1), self.X(x2), self.Y(y2)
        R = max(1.0, r * self.s)
        w = max(1, int(round(width * self.s))) if width else 0
        if fill:
            # Two overlapping bars plus four corner disks.
            self.cv.create_rectangle(X1 + R, Y1, X2 - R, Y2,
                                     fill=fill, outline="")
            self.cv.create_rectangle(X1, Y1 + R, X2, Y2 - R,
                                     fill=fill, outline="")
            for cx, cy in ((X1 + R, Y1 + R), (X2 - R, Y1 + R),
                           (X1 + R, Y2 - R), (X2 - R, Y2 - R)):
                self.cv.create_oval(cx - R, cy - R, cx + R, cy + R,
                                    fill=fill, outline="")
        if outline and w:
            self.cv.create_line(X1 + R, Y1, X2 - R, Y1, fill=outline, width=w)
            self.cv.create_line(X1 + R, Y2, X2 - R, Y2, fill=outline, width=w)
            self.cv.create_line(X1, Y1 + R, X1, Y2 - R, fill=outline, width=w)
            self.cv.create_line(X2, Y1 + R, X2, Y2 - R, fill=outline, width=w)
            # Tk arcs: 0° is 3 o'clock, counterclockwise.
            box = (
                (X1, Y1, X1 + 2 * R, Y1 + 2 * R, 90),
                (X2 - 2 * R, Y1, X2, Y1 + 2 * R, 0),
                (X2 - 2 * R, Y2 - 2 * R, X2, Y2, 270),
                (X1, Y2 - 2 * R, X1 + 2 * R, Y2, 180),
            )
            for a, b, c, d, start in box:
                self.cv.create_arc(a, b, c, d, start=start, extent=90,
                                   style="arc", outline=outline, width=w)

    def _rect_panel(self, x0, y0, x1, y1):
        """A rectangular crew-panel body, same surface as O6."""
        ow = max(2, int(2 * self.s))
        self._poly([(x0 + 5, y0 + 6), (x1 + 5, y0 + 6),
                    (x1 + 5, y1 + 6), (x0 + 5, y1 + 6)],
                   fill="#1a1a1a", outline="", width=0)
        self._rect(x0, y0, x1, y1, fill=C_PANEL, outline=C_INK, width=ow)
        self._line(x0, y0, x1, y0, fill=C_PANEL_HI, width=ow)
        self._line(x0, y0, x0, y1, fill=C_PANEL_HI, width=ow)
        self._line(x0, y1, x1, y1, fill=C_PANEL_LO, width=ow)
        self._line(x1, y0, x1, y1, fill=C_PANEL_LO, width=ow)

    def _dim_caption(self, y, text, size, x0, x1, tick=8, tick_r=None,
                     at=0.63):
        """Dimension bar: rule interrupted by `text`, ticks at both ends.

        voting2.png puts GPC STATUS / FAILED GPC right of centre (`at`)
        with a long left rule and a short right one.  Ticks hang down;
        the GPC STATUS right tick is the longer of the two.
        """
        if tick_r is None:
            tick_r = tick
        f = self._tkfont(size)
        tw = f.measure(text) / max(self.s, 0.01)
        gap = 6
        cx = x0 + at * (x1 - x0)
        self._text(cx, y, text, size=size)
        w = max(1, int(round(1.25 * self.s)))
        left_end = cx - tw / 2.0 - gap
        right_start = cx + tw / 2.0 + gap
        if left_end > x0:
            self._line(x0, y, left_end, y, fill=C_INK, width=w)
        if x1 > right_start:
            self._line(right_start, y, x1, y, fill=C_INK, width=w)
        self._line(x0, y, x0, y + tick, fill=C_INK, width=w)
        self._line(x1, y, x1, y + tick_r, fill=C_INK, width=w)

    def _fastener(self, cx, cy, r=16):
        """Phillips-head panel screw, as at the top-left of voting2.png."""
        ow = max(1, int(self.s))
        self._oval(cx - r, cy - r, cx + r, cy + r,
                   fill=C_PANEL_HI, outline=C_INK, width=ow)
        self._oval(cx - r * 0.70, cy - r * 0.70, cx + r * 0.70, cy + r * 0.70,
                   fill=C_PANEL, outline=C_INK, width=ow)
        a = r * 0.40
        pw = max(2, int(round(2.0 * self.s)))
        self._line(cx - a, cy, cx + a, cy, fill=C_INK, width=pw)
        self._line(cx, cy - a, cx, cy + a, fill=C_INK, width=pw)

    def _mesh_lamp(self, x1, y1, x2, y2, on):
        """Small square lamp with a 4×4 mesh, the voting2.png indicator."""
        fill = C_LAMP_ON if on else C_LAMP_OFF
        ow = max(1, int(self.s))
        self._rect(x1, y1, x2, y2, fill=fill, outline=C_INK, width=ow)
        if on:
            return
        # Unlit: the 4×4 mesh of voting2.png.  Lit, the mesh washes out
        # to a solid white square.
        gw = max(1, int(round(self.s)))
        n = LAMP_GRID
        for i in range(1, n):
            t = i / float(n)
            x = x1 + t * (x2 - x1)
            y = y1 + t * (y2 - y1)
            self._line(x, y1, x, y2, fill=C_INK, width=gw)
            self._line(x1, y, x2, y, fill=C_INK, width=gw)

    def _bracket(self, x, y1, y2, tick=10):
        w = max(2, int(1.5 * self.s))
        self._line(x, y1, x + tick, y1, fill=C_INK, width=w)
        self._line(x, y1, x, y2, fill=C_INK, width=w)
        self._line(x, y2, x + tick, y2, fill=C_INK, width=w)

    # ---- layout / draw --------------------------------------------------

    def _layout(self):
        """Vertical rhythm from glyph bounds, same idea as panelO6.py."""
        pad = 10
        th12 = self._th(12)
        th11 = self._th(11)
        L = {}
        y = MARGIN + pad

        # GPC STATUS and FAILED GPC sit close, as in Figure 3-27.
        y += th12
        L["gpc_status"] = y
        y += th12 + 4 + th11
        L["failed_gpc"] = y
        y += th11 + pad

        y += th12
        L["col_nums"] = y
        y += th12 + pad

        L["bezel0"] = y
        L["grid0"] = y + GRID_PAD
        y = L["grid0"] + GRID_SPAN
        L["grid1"] = y
        L["bezel1"] = y + GRID_PAD
        L["bottom"] = L["bezel1"] + MARGIN
        return L

    def _cell(self, row, col):
        x1 = GRID_X0 + col * (CELL + GAP)
        y1 = self.L["grid0"] + row * (CELL + GAP)
        return x1, y1, x1 + CELL, y1 + CELL

    def redraw(self):
        # First pass needs a scale so _th() can measure; _layout then
        # fixes REF_H and we scale again to the true aspect.
        if self.s <= 0:
            self.s = 1.0
        L = self._layout()
        self.L = L
        self.REF_H = L["bottom"]
        self._scale()
        L = self._layout()
        self.L = L
        self.REF_H = L["bottom"]

        self.cv.delete("all")
        self._hits = []

        mx0, my0 = MARGIN, MARGIN
        mx1, my1 = REF_W - MARGIN, L["bottom"] - MARGIN
        self._rect_panel(mx0, my0, mx1, my1)

        self._fastener(MARGIN + 20,
                       (L["gpc_status"] + L["failed_gpc"]) / 2.0)
        self._dim_caption(L["gpc_status"], "GPC STATUS", 12,
                          BEZEL_X0, BEZEL_X1, tick=7, tick_r=14)
        self._dim_caption(L["failed_gpc"], "FAILED GPC", 11,
                          BEZEL_X0, BEZEL_X1, tick=7, tick_r=8)

        for col in range(N):
            x1, _, x2, _ = self._cell(0, col)
            self._text((x1 + x2) / 2.0, L["col_nums"], str(col + 1), size=12)

        self._round_rect(BEZEL_X0, L["bezel0"], BEZEL_X1, L["bezel1"],
                         RADIUS, fill=C_PANEL, outline=C_INK, width=2.5)

        gy0, gy1 = L["bezel0"], L["bezel1"]
        self._bracket(BRACKET_X, gy0, gy1, tick=8)
        # voting2.png: VOTING sits against rows 1-3, GPC against rows 4-5.
        _, vt0, _, vt1 = self._cell(0, 0)
        _, _, _, vt1 = self._cell(2, 0)
        _, gp0, _, gp1 = self._cell(3, 0)
        _, _, _, gp1 = self._cell(4, 0)
        self._vtext_span(VTEXT_X, vt0, vt1, "VOTING", size=11)
        self._vtext_span(VTEXT_X, gp0, gp1, "GPC", size=11)

        for row in range(N):
            _, y1, _, y2 = self._cell(row, 0)
            self._text(ROW_NUM_X, (y1 + y2) / 2.0, str(row + 1), size=12)

        for row in range(N):
            for col in range(N):
                self._draw_cell(row, col)

    def _draw_cell(self, row, col):
        x1, y1, x2, y2 = self._cell(row, col)
        ow = max(1, int(self.s))
        self._rect(x1, y1, x2, y2, fill=C_PANEL, outline=C_INK, width=ow)
        cx = (x1 + x2) / 2.0
        # voting2.png: the number / lamp sits in the upper half of the cell;
        # (Y) and (W) below it are colour notes, not drawn.
        upper = y1 + CELL * 0.38
        if row == col:
            self._text(cx, upper, str(row + 1), size=22, fill=C_DIAG)
            return
        side = CELL * LAMP_FRAC
        lx1, ly1 = cx - side / 2.0, upper - side / 2.0
        lx2, ly2 = cx + side / 2.0, upper + side / 2.0
        self._mesh_lamp(lx1, ly1, lx2, ly2, self.lamps[row][col])
        self._hits.append((row, col,
                           self.X(lx1), self.Y(ly1),
                           self.X(lx2), self.Y(ly2)))

    # ---- state ----------------------------------------------------------

    def _dump_state(self, why):
        log(why)
        for row in range(N):
            bits = []
            for col in range(N):
                if row == col:
                    bits.append("-")
                else:
                    bits.append("1" if self.lamps[row][col] else "0")
            log("  row %d  %s" % (row + 1, " ".join(bits)))

    def toggle(self, row, col):
        """Toggle the lamp at 0-based (row, col).  Diagonal is a no-op."""
        if not (0 <= row < N and 0 <= col < N):
            return
        if row == col:
            log("%d%d  ignored (no lamp on the diagonal)" % (row + 1, col + 1))
            return
        old = "ON" if self.lamps[row][col] else "OFF"
        self.lamps[row][col] = not self.lamps[row][col]
        new = "ON" if self.lamps[row][col] else "OFF"
        log("%d%d  %s -> %s" % (row + 1, col + 1, old, new))
        self.redraw()

    def _digit(self, ch):
        """Feed one '1'..'5' into the pair buffer."""
        n = int(ch)
        if self._pending is None:
            self._pending = n
            return
        row, col = self._pending - 1, n - 1
        self._pending = None
        self.toggle(row, col)

    def _on_key(self, event):
        ch = event.char
        if event.keysym in ("KP_1", "KP_2", "KP_3", "KP_4", "KP_5"):
            ch = event.keysym[-1]
        if event.keysym in ("Escape", "Return"):
            self._pending = None
            return "break"
        if ch in "12345":
            self._digit(ch)
        return "break"

    def _find(self, x, y):
        for row, col, x1, y1, x2, y2 in self._hits:
            if x1 <= x <= x2 and y1 <= y <= y2:
                return row, col
        return None

    def _on_motion(self, event):
        hit = self._find(event.x, event.y)
        want = hit is not None
        if want != self._cursor_hits:
            self._cursor_hits = want
            self.cv.configure(cursor="hand2" if want else "")

    def _on_press(self, event):
        hit = self._find(event.x, event.y)
        if hit is None:
            self.cv.focus_set()
            return
        self.toggle(hit[0], hit[1])
        self.cv.focus_set()


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Space Shuttle GPC STATUS / FAILED GPC voting matrix")
    ap.add_argument("--size", type=int, default=FULL_SIZE, metavar="N",
                    help="Scale: 768 is full size (default), 512 is 2/3, "
                         "384 is half, etc.")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 560x600+80+20 (overrides --size; "
                         "also NSTS_VOTING_GEOMETRY)")
    args = ap.parse_args(argv)
    if args.size <= 0:
        raise SystemExit("voting: --size must be a positive integer")

    root = tk.Tk()
    root.resizable(True, True)
    panel = VotingPanel(root, size=args.size)
    geom = args.geometry or os.environ.get("NSTS_VOTING_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("voting: bad --geometry %r: %s" % (geom, e))
    else:
        # REF_H is known after a layout pass; do one at s=1 so the
        # default window matches the design.
        panel.s = 1.0
        panel.L = panel._layout()
        panel.REF_H = panel.L["bottom"]
        w, h = scaled_wh(REF_W, panel.REF_H, args.size)
        root.geometry("%dx%d" % (w, h))
    root._panel = panel
    root.mainloop()


if __name__ == "__main__":
    main()
