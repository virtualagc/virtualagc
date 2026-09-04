#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of the Space Shuttle DPS keyboard.

Eight rows of four square momentary pushbuttons, the same layout as the
commander/pilot keyboards (SCOM / shuttleCrewInterface.py).  Presses and
releases print to stdout.  Discrete signalling to yaGPC2 is not wired yet.

Styling follows panelO6.py: gull-grey panel, Helvetica legends, the
window does not steal keyboard focus.  The keys themselves are black
with white lettering.

Usage:
    python3 stsKeyboard.py
    python3 stsKeyboard.py --geometry 650x1280+80+20
"""

import argparse
import os
import subprocess
import tkinter as tk
import tkinter.font as tkfont

# Each key is one or two legend lines, centered in the button.
KEYS = (
    (("FAULT", "SUMM"), ("SYS", "SUMM"), ("MSG", "RESET"), ("ACK",)),
    (("GPC/", "CRT"),   ("A",),          ("B",),           ("C",)),
    (("I/O", "RESET"),  ("D",),          ("E",),           ("F",)),
    (("ITEM",),         ("1",),          ("2",),           ("3",)),
    (("EXEC",),         ("4",),          ("5",),           ("6",)),
    (("OPS",),          ("7",),          ("8",),           ("9",)),
    (("SPEC",),         ("-",),          ("0",),           ("+",)),
    (("RESUME",),       ("CLEAR",),      (".",),           ("PRO",)),
)
NROW = 8
NCOL = 4

# Hex keypad: 0-9, A-F, -, +.  The period is drawn as a disc, not a glyph.
HEX_CAPTIONS = frozenset("0123456789ABCDEF-+")

# Other-key legends use the size EXEC had on the original 88 px keys (10 pt
# on this display).  Hex legends are 1.6x that.  KEY_REF is large enough
# that RESUME / CLEAR / two-line labels stay inside the button at 10 pt.
OTHER_PTS_REF = 10
HEX_FONT_SCALE = 1.6
KEY_REF = 140
GAP_RATIO = 1.0 / 8.0
GAP_REF = KEY_REF * GAP_RATIO
REF_W = int(round(NCOL * KEY_REF + (NCOL + 1) * GAP_REF))
REF_H = int(round(NROW * KEY_REF + (NROW + 1) * GAP_REF))

# Same gull grey as panelO6.py; keys are black on that surface.
C_WINDOW = "#2a2a2a"
C_PANEL = "#c6c3b6"
C_KEY = "#1a1a1a"
C_KEY_DOWN = "#000000"
C_KEY_HI = "#5a5a5a"
C_KEY_LO = "#000000"
C_LEGEND = "#f4f4f4"


def log(msg):
    print("stsKeyboard: %s" % msg, flush=True)


def key_id(lines):
    """Single-line name for the log: 'FAULT SUMM', 'GPC/CRT', 'A'."""
    if len(lines) == 1:
        return lines[0]
    if lines[0].endswith("/"):
        return lines[0] + lines[1]
    return " ".join(lines)


def key_kind(lines):
    if lines == (".",):
        return "dot"
    if len(lines) == 1 and lines[0] in HEX_CAPTIONS:
        return "hex"
    return "other"


def _active_window():
    try:
        out = subprocess.run(
            ["xprop", "-root", "_NET_ACTIVE_WINDOW"],
            capture_output=True, text=True, timeout=5,
        ).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    import re
    m = re.search(r"(0x[0-9a-fA-F]+)", out)
    return m.group(1) if m and int(m.group(1), 16) else None


def _dont_steal_focus(root):
    """Map without taking the keyboard.  Best-effort; see panelO6.py."""

    def refuse(w):
        try:
            w.configure(takefocus=0)
        except tk.TclError:
            pass
        for child in w.winfo_children():
            refuse(child)

    refuse(root)
    root.bind("<Key>", lambda _e: "break")
    previous = _active_window()
    root.withdraw()
    root.update_idletasks()
    try:
        subprocess.run(
            ["xprop", "-id", str(root.winfo_id()),
             "-f", "_NET_WM_USER_TIME", "32c",
             "-set", "_NET_WM_USER_TIME", "0"],
            check=False, stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        pass
    root.deiconify()

    def give_it_back():
        if not previous:
            return
        try:
            subprocess.run(
                ["wmctrl", "-i", "-a", previous],
                check=False, stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL, timeout=5,
            )
        except (OSError, subprocess.SubprocessError):
            pass

    root.after(400, give_it_back)


class STSKeyboard:
    def __init__(self, root):
        self.root = root
        root.title("STS Keyboard")
        root.configure(bg=C_PANEL)
        root.minsize(200, 360)

        self._held = None          # (row, col) while the mouse is down
        self._hits = []
        self._wh = (0, 0)
        self._cursor_hits = False
        self._font_cache = {}

        self.cv = tk.Canvas(root, bg=C_PANEL, highlightthickness=0,
                            width=REF_W, height=REF_H)
        self.cv.pack(fill="both", expand=True)
        self.cv.bind("<ButtonPress-1>", self._on_press)
        self.cv.bind("<ButtonRelease-1>", self._on_release)
        self.cv.bind("<Motion>", self._on_motion)
        self.cv.bind("<Configure>", self._on_configure)
        self.cv.bind("<Leave>", lambda _e: self.cv.configure(cursor=""))

    def _on_configure(self, event):
        if event.widget is not self.cv:
            return
        if (event.width, event.height) == self._wh:
            return
        if event.width < 40 or event.height < 40:
            return
        self._wh = (event.width, event.height)
        self.redraw()

    def _layout(self):
        cw = max(self.cv.winfo_width(), 40)
        ch = max(self.cv.winfo_height(), 40)
        r = GAP_RATIO
        k = min(cw / (NCOL + (NCOL + 1) * r),
                ch / (NROW + (NROW + 1) * r))
        g = r * k
        grid_w = NCOL * k + (NCOL + 1) * g
        grid_h = NROW * k + (NROW + 1) * g
        ox = (cw - grid_w) / 2.0
        oy = (ch - grid_h) / 2.0
        cells = []
        for row in range(NROW):
            for col in range(NCOL):
                x1 = ox + g + col * (k + g)
                y1 = oy + g + row * (k + g)
                cells.append((x1, y1, x1 + k, y1 + k))
        return k, g, cells

    def _tkfont(self, pts, bold=True):
        pts = max(6, int(pts))
        key = (pts, bold)
        font = self._font_cache.get(key)
        if font is None:
            font = tkfont.Font(family="Helvetica", size=pts,
                               weight="bold" if bold else "normal")
            self._font_cache[key] = font
        return font

    def _pts_for(self, kind, k):
        other = max(6, int(round(OTHER_PTS_REF * k / float(KEY_REF))))
        if kind == "hex":
            return max(6, int(round(other * HEX_FONT_SCALE)))
        return other

    def redraw(self):
        self.cv.delete("all")
        self._hits = []
        k, _g, cells = self._layout()
        held = self._held
        for i, (x1, y1, x2, y2) in enumerate(cells):
            row, col = divmod(i, NCOL)
            down = held == (row, col)
            self._draw_key(x1, y1, x2, y2, KEYS[row][col], down, k)
            self._hits.append((row, col, x1, y1, x2, y2))

    def _draw_key(self, x1, y1, x2, y2, lines, down, k):
        fill = C_KEY_DOWN if down else C_KEY
        dx = 1 if down else 0
        self.cv.create_rectangle(x1, y1, x2, y2, fill=fill, outline="#000000",
                                 width=1)
        hi, lo = (C_KEY_LO, C_KEY_HI) if down else (C_KEY_HI, C_KEY_LO)
        self.cv.create_line(x1 + 1, y1 + 1, x2 - 1, y1 + 1, fill=hi)
        self.cv.create_line(x1 + 1, y1 + 1, x1 + 1, y2 - 1, fill=hi)
        self.cv.create_line(x1 + 1, y2 - 1, x2 - 1, y2 - 1, fill=lo)
        self.cv.create_line(x2 - 1, y1 + 1, x2 - 1, y2 - 1, fill=lo)

        kind = key_kind(lines)
        cx = (x1 + x2) / 2.0 + dx
        cy = (y1 + y2) / 2.0 + dx
        if kind == "dot":
            other = self._tkfont(self._pts_for("other", k))
            d = float(other.measure("o"))
            r = d / 2.0
            self.cv.create_oval(cx - r, cy - r, cx + r, cy + r,
                                fill=C_LEGEND, outline="")
            return
        font = self._tkfont(self._pts_for(kind, k))
        ls = font.metrics("linespace")
        n = len(lines)
        if n == 1:
            self.cv.create_text(cx, cy, text=lines[0], fill=C_LEGEND,
                                font=font, anchor="c")
        else:
            total = n * ls
            y0 = cy - total / 2.0 + ls / 2.0
            for i, line in enumerate(lines):
                self.cv.create_text(cx, y0 + i * ls, text=line, fill=C_LEGEND,
                                    font=font, anchor="c")

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
            return
        self._held = hit
        log("%s  down" % key_id(KEYS[hit[0]][hit[1]]))
        self.redraw()

    def _on_release(self, event):
        if self._held is None:
            return
        row, col = self._held
        log("%s  up" % key_id(KEYS[row][col]))
        self._held = None
        self.redraw()


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Space Shuttle DPS keyboard")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 650x1280+80+20")
    args = ap.parse_args(argv)

    root = tk.Tk()
    kb = STSKeyboard(root)
    geom = args.geometry or os.environ.get("NSTS_KEYBOARD_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("stsKeyboard: bad --geometry %r: %s" % (geom, e))
    else:
        root.geometry("%dx%d" % (REF_W, REF_H))
    _dont_steal_focus(root)
    root._kb = kb
    root.mainloop()


if __name__ == "__main__":
    main()
