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
import queue
import socket
import struct
import subprocess
import threading
import time
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
# A PRESSED KEY INVERTS.  Black going to a slightly blacker black, with a
# swapped bevel and a 1 px shift, could not be seen without staring at the key
# -- least of all a script's key, lit for a fraction of a second.  A near-white
# face with a black legend and a dark inset border stands out among 31 black
# keys from across the room.  Change these two for another look (amber, say).
C_KEY_PRESSED = "#f0f0f0"
C_LEGEND_PRESSED = "#000000"
C_KEY_PRESSED_EDGE = "#303030"
PRESS_SINK = 0.03              # legend shift when pressed, per unit of key size
C_KEY_HI = "#5a5a5a"
C_KEY_LO = "#000000"
C_LEGEND = "#f4f4f4"


# The MEDS keyboard buses, as MEDS2.py's busConfig has them (_KYBD1.._KYBD3):
# UDP multicast, one datagram per keystroke, holding the key's scan code as a
# single big-endian halfword.
MCAST_GROUP = "239.255.1.1"
KYBD_PORT = {1: 6931, 2: 6932, 3: 6933}

# The ports above are what the default base (6900) gives; shifting the base
# moves them with it, so a second complete simulation can run beside the
# first without the two fighting over sockets.  The same rule and the same
# NSTS_BUS_PORT_BASE that yaGPC2 (--port-base), MEDS2.py and discretePanel/
# use.
PORT_BASE_DEFAULT = 6900
PORT_BASE = PORT_BASE_DEFAULT


def setPortBase(base):
    """Shift every keyboard port by base - 6900.  Call BEFORE opening one."""
    global PORT_BASE
    base = int(base)
    shift = base - PORT_BASE
    if shift:
        for _n in KYBD_PORT:
            KYBD_PORT[_n] += shift
    PORT_BASE = base
    return PORT_BASE


setPortBase(int(os.environ.get("NSTS_BUS_PORT_BASE", PORT_BASE_DEFAULT)))

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


# A key that arrives from the bus -- a script typing it -- shows pressed for
# this long.  Still shorter than a script's 0.35 s between keys, so a run of
# the same key reads as separate presses.
FLASH_S = 0.3
# Our own clicks come back to us on the multicast loop; one arriving this soon
# after we sent the same code is that echo, not someone else's press.
ECHO_S = 1.0


class KeyboardBus:
    """One MEDS keyboard bus: sends this keyboard's keys, and remembers them
    so their echo can be told from a key someone else puts on the bus."""

    def __init__(self, n):
        self.n = n
        self.port = KYBD_PORT[n]
        self._sent = []            # (scan, monotonic time) of our recent sends
        # The same interface MEDS2.py's buses are pinned to, or the datagram
        # leaves by the default route and its listeners never see it.
        iface = os.environ.get("NSTS_BUS_IFACE", "127.0.0.1")
        self.iface = iface
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
        self._sent.append((scan, time.monotonic()))
        return True

    def is_own_echo(self, scan):
        """True, once, for a code we sent within ECHO_S."""
        now = time.monotonic()
        self._sent = [(c, t) for c, t in self._sent if now - t < ECHO_S]
        for i, (c, _t) in enumerate(self._sent):
            if c == scan:
                del self._sent[i]
                return True
        return False

    def receiver(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind(("", self.port))
        s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                     struct.pack("4s4s", socket.inet_aton(MCAST_GROUP),
                                 socket.inet_aton(self.iface)))
        return s


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
    def __init__(self, root, size=FULL_SIZE, bus=None, title=None):
        self.root = root
        self.bus = bus
        # JUST THE NUMBER, because the window is small.  "STS Keyboard
        # (KYBD1)" truncated to "STS Key..." in a --size 512 title bar, and
        # at the smaller sizes a many-CRT run wants, so did "KYBD1": WHICH
        # keyboard is the only thing the caption has to carry, and anyone
        # can see it is a keyboard.  1 is the left keyboard, 2 the right
        # and 3 the aft one; panelO6.py's IDP/CRT SEL switches say which IDP
        # the forward two reach.  --title overrides it.
        root.title(title or (str(bus.n) if bus else "STS Keyboard"))
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

        # KEYS FROM THE BUS SHOW TOO.  A crew script types on this keyboard's
        # bus directly, so without this the keyboard sat still through a whole
        # demonstration while its keys were being pressed.
        self._by_scan = {}
        for row in range(NROW):
            for col in range(NCOL):
                code = SCAN.get(key_id(KEYS[row][col]))
                if code is not None:
                    self._by_scan[code] = (row, col)
        self._flash = {}           # (row, col) -> monotonic time it ends
        self._rx = queue.Queue()
        if self.bus is not None:
            threading.Thread(target=self._listen, daemon=True).start()
            root.after(30, self._poll_bus)

    def _listen(self):
        try:
            s = self.bus.receiver()
        except OSError as e:
            log("KYBD%d: cannot listen for keys from the bus: %s" % (self.bus.n, e))
            return
        while True:
            try:
                data, _ = s.recvfrom(64)
            except OSError:
                return
            if len(data) >= 2:
                self._rx.put(struct.unpack(">H", data[:2])[0])

    def _poll_bus(self):
        now = time.monotonic()
        changed = False
        while True:
            try:
                scan = self._rx.get_nowait()
            except queue.Empty:
                break
            if self.bus.is_own_echo(scan):
                continue
            where = self._by_scan.get(scan)
            if where is None:
                continue
            self._flash[where] = now + FLASH_S
            log("%s  pressed on the bus" % key_id(KEYS[where[0]][where[1]]))
            changed = True
        for where in [w for w, t in self._flash.items() if t <= now]:
            del self._flash[where]
            changed = True
        if changed:
            self.redraw()
        self.root.after(30, self._poll_bus)

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
            down = held == (row, col) or (row, col) in self._flash
            self._draw_key(x1, y1, x2, y2, KEYS[row][col], down, k)
            self._hits.append((row, col, x1, y1, x2, y2))

    def _draw_key(self, x1, y1, x2, y2, lines, down, k):
        legend = C_LEGEND_PRESSED if down else C_LEGEND
        if down:
            edge = max(2, int(round(k * 0.05)))
            dx = max(1, int(round(k * PRESS_SINK)))
            self.cv.create_rectangle(x1, y1, x2, y2, fill=C_KEY_PRESSED_EDGE,
                                     outline="#000000", width=1)
            self.cv.create_rectangle(x1 + edge, y1 + edge + dx / 2.0,
                                     x2 - edge, y2 - edge + dx / 2.0,
                                     fill=C_KEY_PRESSED, outline="")
        else:
            dx = 0
            self.cv.create_rectangle(x1, y1, x2, y2, fill=C_KEY, outline="#000000",
                                     width=1)
            self.cv.create_line(x1 + 1, y1 + 1, x2 - 1, y1 + 1, fill=C_KEY_HI)
            self.cv.create_line(x1 + 1, y1 + 1, x1 + 1, y2 - 1, fill=C_KEY_HI)
            self.cv.create_line(x1 + 1, y2 - 1, x2 - 1, y2 - 1, fill=C_KEY_LO)
            self.cv.create_line(x2 - 1, y1 + 1, x2 - 1, y2 - 1, fill=C_KEY_LO)

        kind = key_kind(lines)
        cx = (x1 + x2) / 2.0 + dx
        cy = (y1 + y2) / 2.0 + dx
        if kind == "dot":
            other = self._tkfont(self._pts_for("other", k))
            d = float(other.measure("o"))
            r = d / 2.0
            self.cv.create_oval(cx - r, cy - r, cx + r, cy + r,
                                fill=legend, outline="")
            return
        font = self._tkfont(self._pts_for(kind, k, lines))
        ls = font.metrics("linespace")
        n = len(lines)
        if n == 1:
            self.cv.create_text(cx, cy, text=lines[0], fill=legend,
                                font=font, anchor="c")
        else:
            total = n * ls
            y0 = cy - total / 2.0 + ls / 2.0
            for i, line in enumerate(lines):
                self.cv.create_text(cx, y0 + i * ls, text=line, fill=legend,
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
    ap.add_argument("--title", metavar="TEXT", default=None,
                    help="window caption (default the keyboard number, 1..3: "
                         "1 left, 2 right, 3 aft)")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range the buses use: the "
                         "keyboard buses are base+31..base+33 (default 6900, "
                         "matching MEDS2.py's busConfig).  The same option as "
                         "on yaGPC2, MEDS2.py and panelO6.py -- give a second "
                         "simulation its own base and the two run side by "
                         "side.  NSTS_BUS_PORT_BASE sets it too.")
    ap.add_argument("--kybd", type=int, choices=sorted(KYBD_PORT), default=1,
                    metavar="N",
                    help="MEDS keyboard bus to send on, 1-3 (default 1: "
                         "IDP1 and IDP3)")
    args = ap.parse_args(argv)
    # Before any socket is opened.
    if args.port_base is not None:
        setPortBase(args.port_base)
    if args.size <= 0:
        raise SystemExit("stsKeyboard: --size must be a positive integer")

    root = tk.Tk()
    kb = STSKeyboard(root, size=args.size, bus=KeyboardBus(args.kybd),
                     title=args.title)
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
