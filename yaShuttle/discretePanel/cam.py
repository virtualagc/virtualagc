#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of the Space Shuttle GPC STATUS / FAILED GPC matrix.

A 5×5 array of indicator lamps: rows are the voting GPC, columns the
failed GPC.  Every lamp fills its cell.  Off the diagonal a lit lamp is
white; ON the diagonal it is yellow and carries the GPC number in black,
because a GPC can vote against ITSELF, and those self-failure votes are what
drive the diagonal.  Digits 1-5 typed as a pair (row, then column) toggle
that lamp, the diagonal included.  There is no visible entry widget.
Clicking a lamp toggles it too.

THE LAMPS FOLLOW THE COMPUTERS.  Unless --no-bus is given, the panel listens
on all five GPC discrete channels (port base + 81 .. + 85): row N comes from
GPC N's fail-discrete register, un-rotated (0x08 votes against N+1 ... 0x01
against N+4, and 0x10 inhibits all four), and the diagonal cell N from GPC
N's computer-fail lamp.  At start-up it asks each computer for both, so it
can be started at any time.  Messages are taken one at a time and a lit lamp
stays lit for at least HOLD_MIN_S, so a vote the flight software sets and
clears within a millisecond still shows, for a video frame and then some.
The keys and clicks still toggle a lamp by hand; the next message from that
computer overrides them.

The layout follows ~/Desktop/voting2.png (the clearest CAM drawing):
dimension-ruled GPC STATUS / FAILED GPC with the titles sitting right of
centre and a rounded bezel.  (Y) and (W) in the drawing are the lit colours
of the diagonal and off-diagonal lamps, not text.  The drawing's small
squares and yellow digits were misread at first: each lamp fills its
enclosure, and the diagonal digits are black legends on yellow lamps.

Styling follows panelO6.py: gull-grey panel, Helvetica legends, a
standard decorated resizable window.  Unlike panelO6.py / stsKeyboard.py
this window *does* take the keyboard, because the lamps are driven by
keystrokes.

Usage:
    python3 cam.py
    python3 cam.py --size 384
    python3 cam.py --geometry 560x600+80+20
    python3 cam.py --port-base 13400      # the emulator's --port-base
    python3 cam.py --no-bus               # keys and clicks only
"""

import argparse
import os
import queue
import socket
import struct
import sys
import threading
import time
import tkinter as tk
import tkinter.font as tkfont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import discretes as D  # noqa: E402

N = 5
# A lit lamp stays lit at least this long, however briefly the computer drove
# it: one frame of 25 fps video with margin, so a sub-millisecond vote is not
# lost between frames.
HOLD_MIN_S = 0.040

# Same gull grey as panelO6.py.
C_PANEL = "#c6c3b6"
C_INK = "#1b1b1b"
C_LAMP_ON = "#ffffff"   # off-diagonal lamp, lit (W)
C_DIAG_ON = "#ffe600"   # diagonal (self-failure) lamp, lit (Y)
# Slightly darker than the pane, so an unlit lamp is a cell you can
# still see without competing with a lit one.
C_LAMP_OFF = "#a4a193"

MARGIN = 16
CELL = 76
# voting2.png: tight gaps; each lamp fills its cell.
GAP = 5
GRID_PAD = 10          # air between the rounded bezel and the cells
RADIUS = 16
# Captions ~half the original point sizes; diagonal numbers ~70%.
# GPC STATUS is ~30% larger than FAILED GPC.
SZ_STATUS = 8
SZ_FAILED = 6
SZ_NUM = 6
SZ_DIAG = 15
SZ_VTEXT = 6
FULL_SIZE = 512        # --size units: 512 is the design window.  NOT 768
                       # like panelO6.py and stsKeyboard.py: this is a small
                       # annunciator matrix beside their full-height panels,
                       # and at their unit the natural window came out tiny.

# Left of the grid: stacked "VOTING GPC", a bracket, then the row numbers.
# VTEXT_X sits in the middle of the air between the pane edge (0) and
# the bracket, so those two gaps match.
BRACKET_X = 58
VTEXT_X = BRACKET_X / 2.0
ROW_NUM_X = 78
GRID_X0 = 102
GRID_SPAN = N * CELL + (N - 1) * GAP
BEZEL_X0 = GRID_X0 - GRID_PAD
BEZEL_X1 = GRID_X0 + GRID_SPAN + GRID_PAD
REF_W = int(BEZEL_X1 + MARGIN)


def log(msg):
    print("voting: %s" % msg, flush=True)


def scaled_wh(w, h, size):
    """Pixel size at --size N, where FULL_SIZE (512) is the design window."""
    f = size / float(FULL_SIZE)
    return max(1, int(round(w * f))), max(1, int(round(h * f)))


class CamPanel:
    def __init__(self, root, size=FULL_SIZE, bus=True):
        self.root = root
        root.title("CAM")
        root.configure(bg=C_PANEL)
        self.size = size

        # Lamps[row][col] is True when ON; lamps[n][n] is GPC n+1's vote
        # against itself.
        self.lamps = [[False] * N for _ in range(N)]
        self.on_since = [[0.0] * N for _ in range(N)]
        self.off_at = [[None] * N for _ in range(N)]
        self.fv = [0] * N          # GPC n+1's raw fail-discrete register
        self.cf = [0] * N          # GPC n+1's computer-fail lamp register
        self._q = queue.Queue()
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
        self.cv = tk.Canvas(root, bg=C_PANEL, highlightthickness=0,
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
        if bus:
            self._start_bus()

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

    def _ink_y(self, y, size):
        """Shift a centre-anchored y so the glyph ink, not the em box, is centred."""
        f = self._tkfont(size)
        return y + (f.metrics("descent") / 2.0) / max(self.s, 0.01)

    def _vtext_packed(self, x, y, text, size=6, fill=C_INK):
        """Stacked caption centred on y.

        Letter pitch is cap-height plus 30% of that height.  A space is
        just the 30% gap, so VOTING / GPC stay two words without a hole.
        """
        font = self._font(size)
        ascent = float(self._tkfont(size).metrics("ascent"))
        gap = 0.30 * ascent
        slots = []
        for ch in text:
            if ch.isspace():
                slots.append((None, gap))
            else:
                slots.append((ch, ascent + gap))
        total = sum(h for _ch, h in slots) or 1.0
        y0 = self.Y(y) - total / 2.0
        cx = self.X(x)
        acc = 0.0
        for ch, h in slots:
            cy = y0 + acc + h / 2.0
            if ch is not None:
                self.cv.create_text(cx, cy, text=ch, fill=fill,
                                    font=font, anchor="c")
            acc += h

    def _rect(self, x1, y1, x2, y2, **kw):
        return self.cv.create_rectangle(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

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

    def _dim_caption(self, y, text, size, x0, x1, cx, tick=8, tick_r=None):
        """Dimension bar: rule interrupted by `text`, ticks at both ends.

        `cx` is the text centre (column 3 of the matrix).  Ticks hang
        down; the GPC STATUS right tick is the longer of the two.
        """
        if tick_r is None:
            tick_r = tick
        f = self._tkfont(size)
        tw = f.measure(text) / max(self.s, 0.01)
        gap = 6
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

    def _bracket(self, x, y1, y2, tick=10):
        w = max(2, int(1.5 * self.s))
        self._line(x, y1, x + tick, y1, fill=C_INK, width=w)
        self._line(x, y1, x, y2, fill=C_INK, width=w)
        self._line(x, y2, x + tick, y2, fill=C_INK, width=w)

    # ---- layout / draw --------------------------------------------------

    def _layout(self):
        """Vertical rhythm from glyph bounds, same idea as panelO6.py."""
        pad = 8
        th_s = self._th(SZ_STATUS)
        th_f = self._th(SZ_FAILED)
        th_n = self._th(SZ_NUM)
        L = {}
        y = MARGIN + pad

        y += th_s
        L["gpc_status"] = y
        y += th_s + 3 + th_f
        L["failed_gpc"] = y
        y += th_f + pad

        y += th_n
        L["col_nums"] = y
        y += th_n + pad

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

        col3 = (self._cell(0, 2)[0] + self._cell(0, 2)[2]) / 2.0
        self._dim_caption(L["gpc_status"], "GPC STATUS", SZ_STATUS,
                          BEZEL_X0, BEZEL_X1, col3, tick=5, tick_r=10)
        self._dim_caption(L["failed_gpc"], "FAILED GPC", SZ_FAILED,
                          BEZEL_X0, BEZEL_X1, col3, tick=5, tick_r=6)

        for col in range(N):
            x1, _, x2, _ = self._cell(0, col)
            self._text((x1 + x2) / 2.0, self._ink_y(L["col_nums"], SZ_NUM),
                       str(col + 1), size=SZ_NUM)

        self._round_rect(BEZEL_X0, L["bezel0"], BEZEL_X1, L["bezel1"],
                         RADIUS, fill=C_PANEL, outline=C_INK, width=2.5)

        gy0, gy1 = L["bezel0"], L["bezel1"]
        self._bracket(BRACKET_X, gy0, gy1, tick=6)
        self._vtext_packed(VTEXT_X, (gy0 + gy1) / 2.0, "VOTING GPC",
                           size=SZ_VTEXT)

        for row in range(N):
            _, y1, _, y2 = self._cell(row, 0)
            cy = self._ink_y((y1 + y2) / 2.0, SZ_NUM)
            self._text(ROW_NUM_X, cy, str(row + 1), size=SZ_NUM)

        for row in range(N):
            for col in range(N):
                self._draw_cell(row, col)

    def _draw_cell(self, row, col):
        """The lamp IS the cell: it fills the enclosure to its outline."""
        x1, y1, x2, y2 = self._cell(row, col)
        ow = max(1, int(self.s))
        on = self.lamps[row][col]
        if row == col:
            fill = C_DIAG_ON if on else C_LAMP_OFF
        else:
            fill = C_LAMP_ON if on else C_LAMP_OFF
        self._rect(x1, y1, x2, y2, fill=fill, outline=C_INK, width=ow)
        if row == col:
            # The GPC number is a black legend on the self-failure lamp.
            cx = (x1 + x2) / 2.0
            cy = (y1 + y2) / 2.0
            self._text(cx, self._ink_y(cy, SZ_DIAG),
                       str(row + 1), size=SZ_DIAG, fill=C_INK)
        self._hits.append((row, col,
                           self.X(x1), self.Y(y1),
                           self.X(x2), self.Y(y2)))

    # ---- the discrete bus ----------------------------------------------

    @staticmethod
    def _channel_receiver(port):
        """A socket on one computer's discrete channel (discretes.receiver()
        binds the module's single PORT; the CAM needs all five)."""
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("", port))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     struct.pack("4s4s", socket.inet_aton(D.GROUP),
                                 socket.inet_aton(D.IFACE)))
        s.settimeout(0.5)
        return s

    def _start_bus(self):
        for g in range(1, N + 1):
            port = D.gpc_port(g)
            try:
                s = self._channel_receiver(port)
            except OSError as e:
                log("GPC %d channel (port %d): %s" % (g, port, e))
                continue
            threading.Thread(target=self._reader, args=(g, s),
                             daemon=True).start()
        log("listening on ports %d-%d" % (D.gpc_port(1), D.gpc_port(N)))
        # The computers hold the registers; a panel started late asks.
        try:
            out = D.sender()
            for g in range(1, N + 1):
                for reg in (D.REG_FAILVOTE, D.REG_CFAIL):
                    D.publish(out, D.REQUEST, reg, 0, port=D.gpc_port(g))
        except OSError as e:
            log("request: %s" % e)
        self.root.after(10, self._pump)

    def _reader(self, g, sock):
        while True:
            try:
                data, _ = sock.recvfrom(2048)
            except socket.timeout:
                continue
            except OSError:
                return
            msg = D.decode(data)
            if msg is None or msg["op"] == D.REQUEST:
                continue
            if msg["reg"] in (D.REG_FAILVOTE, D.REG_CFAIL):
                self._q.put((g, msg))

    def _pump(self):
        """Apply queued messages ONE AT A TIME, in arrival order, then let
        any held lamp whose minimum has run out go dark."""
        now = time.monotonic()
        changed = False
        while True:
            try:
                g, msg = self._q.get_nowait()
            except queue.Empty:
                break
            changed = self._apply(g, msg, now) or changed
        for row in range(N):
            for col in range(N):
                due = self.off_at[row][col]
                if due is not None and now >= due:
                    self.off_at[row][col] = None
                    self.lamps[row][col] = False
                    log("%d%d  OFF (bus, held %.0f ms)"
                        % (row + 1, col + 1, HOLD_MIN_S * 1e3))
                    changed = True
        if changed:
            self.redraw()
        self.root.after(10, self._pump)

    def _apply(self, g, msg, now):
        n = g - 1
        if msg["reg"] == D.REG_FAILVOTE:
            self.fv[n] = D.apply(self.fv[n], msg) & 0x1F
            inhibited = bool(self.fv[n] & 0x10)
            results = [self._drive(n, (n + k) % N,
                                   not inhibited and bool(self.fv[n] & (0x10 >> k)),
                                   now)
                       for k in range(1, N)]
            return any(results)
        self.cf[n] = D.apply(self.cf[n], msg)
        return self._drive(n, n, bool(self.cf[n] & D.CFAIL_LIT), now)

    def _drive(self, row, col, on, now):
        """Set a lamp from the bus, honouring HOLD_MIN_S.  True if it moved."""
        if on:
            self.off_at[row][col] = None
            if self.lamps[row][col]:
                return False
            self.lamps[row][col] = True
            self.on_since[row][col] = now
            log("%d%d  ON (bus)" % (row + 1, col + 1))
            return True
        if not self.lamps[row][col] or self.off_at[row][col] is not None:
            return False
        due = self.on_since[row][col] + HOLD_MIN_S
        if now < due:
            self.off_at[row][col] = due     # _pump puts it out
            return False
        self.lamps[row][col] = False
        log("%d%d  OFF (bus)" % (row + 1, col + 1))
        return True

    # ---- state ----------------------------------------------------------

    def _dump_state(self, why):
        log(why)
        for row in range(N):
            bits = ["1" if self.lamps[row][col] else "0" for col in range(N)]
            log("  row %d  %s" % (row + 1, " ".join(bits)))

    def toggle(self, row, col):
        """Toggle the lamp at 0-based (row, col); row == col is a self-vote."""
        if not (0 <= row < N and 0 <= col < N):
            return
        old = "ON" if self.lamps[row][col] else "OFF"
        self.lamps[row][col] = not self.lamps[row][col]
        self.on_since[row][col] = time.monotonic()
        self.off_at[row][col] = None
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
                    help="Scale: 512 is full size (default), 384 is 3/4, "
                         "256 is half, 768 is 1.5x, etc.")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 560x600+80+20 (overrides --size; "
                         "also NSTS_CAM_GEOMETRY)")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the bus port range, as given to yaGPC2's "
                         "--port-base (default 6900, or NSTS_BUS_PORT_BASE)")
    ap.add_argument("--no-bus", action="store_true",
                    help="do not listen to the computers; keys and clicks only")
    args = ap.parse_args(argv)
    if args.size <= 0:
        raise SystemExit("voting: --size must be a positive integer")
    if args.port_base is not None:
        D.set_port_base(args.port_base)

    root = tk.Tk()
    root.resizable(True, True)
    panel = CamPanel(root, size=args.size, bus=not args.no_bus)
    geom = args.geometry or os.environ.get("NSTS_CAM_GEOMETRY")
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
