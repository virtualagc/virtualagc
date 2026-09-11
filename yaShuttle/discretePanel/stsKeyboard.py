#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of the Space Shuttle DPS keyboard.

Eight rows of four square momentary pushbuttons, the same layout as the
commander/pilot keyboards (SCOM / shuttleCrewInterface.py).  Pressing a
key sends it to MEDS2.py on a MEDS keyboard bus, exactly as a keystroke
typed into an MDU window does; presses and releases also print to stdout.

The keyboard bus is chosen with --kybd.  MEDS2.py's IDPs listen as
follows (MEDSConf there): KYBD1 -> IDP1, IDP3; KYBD2 -> IDP2, IDP3;
KYBD3 -> IDP2, IDP4.  An MDU echoes the scratch pad for the first
keyboard its primary IDP listens to:
    KYBD1  crt1 crt3 cdr1 cdr2 plt2 mfd2
    KYBD2  crt2 plt1 mfd1
    KYBD3  crt4 afd1

Styling follows panelO6.py: gull-grey panel, Helvetica legends, the
window does not steal keyboard focus.  The keys themselves are black
with white lettering.

Usage:
    python3 stsKeyboard.py
    python3 stsKeyboard.py --kybd 2
    python3 stsKeyboard.py --size 512
    python3 stsKeyboard.py --geometry 520x1020+80+20
"""

import argparse
import os
import socket
import struct
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
# on this display).  Hex legends are 1.6x that; RESUME is 0.75x other.
# KEY_REF leaves about half a character of margin at 10 pt (CLEAR is the
# widest remaining other-key once RESUME is reduced).
OTHER_PTS_REF = 10
HEX_FONT_SCALE = 1.6
RESUME_FONT_SCALE = 0.75
KEY_REF = 110
GAP_RATIO = 1.0 / 8.0
GAP_REF = KEY_REF * GAP_RATIO
REF_W = int(round(NCOL * KEY_REF + (NCOL + 1) * GAP_REF))
REF_H = int(round(NROW * KEY_REF + (NROW + 1) * GAP_REF))
FULL_SIZE = 768        # --size units: 768 is the design (full) window, as in panelO6.py

# Same gull grey as panelO6.py; keys are black on that surface.
C_WINDOW = "#2a2a2a"
C_PANEL = "#c6c3b6"
C_KEY = "#1a1a1a"
C_KEY_DOWN = "#000000"
C_KEY_HI = "#5a5a5a"
C_KEY_LO = "#000000"
C_LEGEND = "#f4f4f4"


# The MEDS keyboard buses, as MEDS2.py's busConfig has them (_KYBD1.._KYBD3):
# UDP multicast, one datagram per keystroke, holding the key's scan code as a
# single big-endian halfword.
MCAST_GROUP = "239.255.1.1"
KYBD_PORT = {1: 6931, 2: 6932, 3: 6933}

# Scan codes by legend, from KYBD.DEUKey in MEDS2.py, which is where the IDP
# looks them up (KYBD.byScan).  They are the row/column strobe pattern the
# keyboard puts on the bus, not the 5-bit code the GPC is eventually given.
SCAN = {
    "FAULT SUMM": 0xFFE1, "SYS SUMM": 0xFFE9, "MSG RESET": 0xFFF1, "ACK": 0xFFF9,
    "GPC/CRT": 0xFFC1,    "A": 0xFFC9,        "B": 0xFFD1,         "C": 0xFFD9,
    "I/O RESET": 0xFF3A,  "D": 0xFF7A,        "E": 0xFFBA,         "F": 0xFFFA,
    "ITEM": 0xFE3A,       "1": 0xFE7A,        "2": 0xFEFB,         "3": 0xFEFA,
    "EXEC": 0xF9FB,       "4": 0xFBFB,        "5": 0xFDFB,         "6": 0xFFFB,
    "OPS": 0xF1FB,        "7": 0xF3FB,        "8": 0xF5FB,         "9": 0xF7FB,
    "SPEC": 0xCFFC,       "-": 0xDFFC,        "0": 0xEFFC,         "+": 0xFFFC,
    "RESUME": 0x8FFC,     "CLEAR": 0x9FFC,    ".": 0xAFFC,         "PRO": 0xBFFC,
}


def log(msg):
    print("stsKeyboard: %s" % msg, flush=True)


class KeyboardBus:
    """The sending end of one MEDS keyboard bus."""

    def __init__(self, n):
        self.n = n
        self.port = KYBD_PORT[n]
        # The same interface MEDS2.py's buses are pinned to, or the datagram
        # leaves by the default route and its listeners never see it.
        iface = os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 128)
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                     socket.inet_aton(iface))
        self.sock = s

    def send(self, scan):
        try:
            self.sock.sendto(struct.pack(">H", scan), (MCAST_GROUP, self.port))
        except OSError as e:
            log("KYBD%d: send failed: %s" % (self.n, e))
            return False
        return True


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


def scaled_wh(w, h, size):
    """Pixel size at --size N, where FULL_SIZE (768) is the design window."""
    f = size / float(FULL_SIZE)
    return max(1, int(round(w * f))), max(1, int(round(h * f)))


class STSKeyboard:
    def __init__(self, root, size=FULL_SIZE, bus=None):
        self.root = root
        self.bus = bus
        root.title("STS Keyboard" + (" (KYBD%d)" % bus.n if bus else ""))
        root.configure(bg=C_PANEL)
        mw, mh = scaled_wh(200, 360, size)
        root.minsize(mw, mh)

        self._held = None          # (row, col) while the mouse is down
        self._hits = []
        self._wh = (0, 0)
        self._cursor_hits = False
        self._font_cache = {}

        cw, ch = scaled_wh(REF_W, REF_H, size)
        self.cv = tk.Canvas(root, bg=C_PANEL, highlightthickness=0,
                            width=cw, height=ch)
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
        pts = max(1, int(round(pts)))
        key = (pts, bold)
        font = self._font_cache.get(key)
        if font is None:
            font = tkfont.Font(family="Helvetica", size=pts,
                               weight="bold" if bold else "normal")
            self._font_cache[key] = font
        return font

    def _pts_for(self, kind, k, lines=()):
        other = max(1, int(round(OTHER_PTS_REF * k / float(KEY_REF))))
        if kind == "hex":
            return max(1, int(round(other * HEX_FONT_SCALE)))
        if lines == ("RESUME",):
            return max(1, int(round(other * RESUME_FONT_SCALE)))
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
        font = self._tkfont(self._pts_for(kind, k, lines))
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
        name = key_id(KEYS[hit[0]][hit[1]])
        # A key goes out when it is pressed, as the MDU window's keydown does.
        if self.bus is not None and self.bus.send(SCAN[name]):
            log("%s  down -> KYBD%d 0x%04X" % (name, self.bus.n, SCAN[name]))
        else:
            log("%s  down" % name)
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
    ap.add_argument("--size", type=int, default=FULL_SIZE, metavar="N",
                    help="Scale: 768 is full size (default), 512 is 2/3, 384 is half, etc.")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 520x1020+80+20 (overrides --size)")
    ap.add_argument("--kybd", type=int, choices=sorted(KYBD_PORT), default=1,
                    metavar="N",
                    help="MEDS keyboard bus to send on, 1-3 (default 1: "
                         "IDP1 and IDP3)")
    args = ap.parse_args(argv)
    if args.size <= 0:
        raise SystemExit("stsKeyboard: --size must be a positive integer")

    root = tk.Tk()
    kb = STSKeyboard(root, size=args.size, bus=KeyboardBus(args.kybd))
    geom = args.geometry or os.environ.get("NSTS_KEYBOARD_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("stsKeyboard: bad --geometry %r: %s" % (geom, e))
    else:
        w, h = scaled_wh(REF_W, REF_H, args.size)
        root.geometry("%dx%d" % (w, h))
    _dont_steal_focus(root)
    root._kb = kb
    root.mainloop()


if __name__ == "__main__":
    main()
