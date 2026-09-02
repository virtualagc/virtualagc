#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of Space Shuttle overhead panel O6.

The GENERAL PURPOSE COMPUTER hardware controls live on panel O6, overhead
of the commander's seat.  This program draws that GPC half of the panel
(the MDM power switches on the left of the physical panel are not yet
included) and lets the controls be operated with the mouse.

Control changes are printed to stdout.  Discrete signalling to yaGPC2 is
intentionally not wired yet.

The figure this layout follows is "GENERAL PURPOSE COMPUTER Hardware
Controls" in the Shuttle Crew Operations Manual (SCOM, USA007587 Rev A,
printed page 2.6-4).  Two rows of that figure are easy to misread:

  * The second row is not a set of slide switches.  Those hatched windows
    are the OUTPUT talkbacks: gray if that GPC may transmit on the
    flight-critical buses, barberpole if it may not.  They are driven by
    GPC output discretes, not by a crew switch of their own.  Until a GPC
    is attached they are approximated from POWER, OUTPUT and MODE.
  * The fifth row is the MODE talkback (RUN, IPL, or barberpole), not a
    control.  It shows RUN while the MODE switch is in RUN, and IPL while
    the IPL pushbutton is held.

The OUTPUT switch itself is the third-row three-position toggle
(BACKUP / NORMAL / TERMINATE).  The MODE switch is the bottom-row
three-position toggle (RUN / STBY / HALT), lever-locked in RUN on the
real hardware; this simulation does not require pulling a lock.

Usage:
    python3 panelO6.py
    python3 panelO6.py --geometry 780x980+100+40
"""

import argparse
import math
import os
import subprocess
import tkinter as tk
import tkinter.font as tkfont

GPCS = ("GPC1", "GPC2", "GPC3", "GPC4", "GPC5")
N_GPC = 5

POWER_POS = ("ON", "OFF")          # up, down
OUTPUT_POS = ("BACKUP", "NORMAL", "TERMINATE")   # up, mid, down
MODE_POS = ("RUN", "STBY", "HALT")               # up, mid, down
IPL_SOURCE_POS = ("MMU 1", "OFF", "MMU 2")       # up, mid, down

# Typical pre-flight: GPC 5 is the BFS computer, OUTPUT in BACKUP.
DEFAULT_POWER = ["ON"] * N_GPC
DEFAULT_OUTPUT = ["NORMAL", "NORMAL", "NORMAL", "NORMAL", "BACKUP"]
DEFAULT_MODE = ["HALT"] * N_GPC
DEFAULT_IPL_SOURCE = "OFF"

# Aircraft-panel greys.  Overhead panels are light gull gray with black
# engraved legends, not the dark of a CRT bezel.
C_WINDOW = "#2a2a2a"
C_PANEL = "#c6c3b6"
C_PANEL_HI = "#dddaca"
C_PANEL_LO = "#8e8b7e"
C_INK = "#1b1b1b"
C_INK_DIM = "#3a3a3a"
C_GUARD = "#d9d6c9"
C_GUARD_LO = "#6a675c"
C_SLOT = "#242422"
C_PADDLE = "#eceadf"
C_PADDLE_LO = "#8a877c"
C_PADDLE_GROOVE = "#4a4a46"
C_BEZEL = "#4a4840"
C_TB_GRAY = "#a3a39c"
C_TB_LEGEND = "#f2f0e6"
C_BTN = "#d5d2c6"
C_BTN_DOWN = "#8f8c80"
C_LOCK = "#c4c1b5"

REF_W = 820
REF_H = 1000

# Position legends (ON/OFF, BACKUP/NORMAL/TERMINATE, RUN/STBY/HALT,
# MMU 1/2).  Side captions and above/below captions share this size.
SETTING_SIZE = 8


def log(msg):
    print("panelO6: %s" % msg, flush=True)


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
    """Map without taking the keyboard.  Best-effort; see discretePanel.py."""

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


class PanelO6:
    def __init__(self, root):
        self.root = root
        root.title("Panel O6  —  GENERAL PURPOSE COMPUTER")
        root.configure(bg=C_WINDOW)
        root.minsize(480, 580)

        self.power = list(DEFAULT_POWER)
        self.output = list(DEFAULT_OUTPUT)
        self.ipl = [False] * N_GPC
        self.mode = list(DEFAULT_MODE)
        self.ipl_source = DEFAULT_IPL_SOURCE
        self._held_ipl = None

        self.cv = tk.Canvas(root, bg=C_WINDOW, highlightthickness=0,
                            width=REF_W, height=REF_H)
        self.cv.pack(fill="both", expand=True)

        self._hits = []          # (kind, index, x1, y1, x2, y2)
        self._bp_cache = {}
        self._font_cache = {}
        self._wh = (0, 0)
        self._cursor_hits = False

        self.cv.bind("<ButtonPress-1>", self._on_press)
        self.cv.bind("<ButtonRelease-1>", self._on_release)
        self.cv.bind("<Motion>", self._on_motion)
        self.cv.bind("<Configure>", self._on_configure)
        self.cv.bind("<Leave>", lambda _e: self.cv.configure(cursor=""))

        self._dump_state("startup")

    # ---- derived talkbacks (local stand-in until yaGPC2 drives them) ----

    def output_tb(self, i):
        if (self.power[i] == "ON"
                and self.output[i] == "NORMAL"
                and self.mode[i] == "RUN"):
            return "GRAY"
        return "BP"

    def mode_tb(self, i):
        if self.ipl[i]:
            return "IPL"
        if self.mode[i] == "RUN":
            return "RUN"
        return "BP"

    def _dump_state(self, why):
        log(why)
        for i, name in enumerate(GPCS):
            log("  %s  POWER=%-3s  OUTPUT=%-9s  MODE=%-4s  IPL=%s  "
                "OUT-tb=%s  MODE-tb=%s"
                % (name, self.power[i], self.output[i], self.mode[i],
                   "ON" if self.ipl[i] else "OFF",
                   self.output_tb(i), self.mode_tb(i)))
        log("  IPL SOURCE=%s" % self.ipl_source)

    def _announce(self, what, old, new):
        if old == new:
            return
        log("%s  %s -> %s" % (what, old, new))

    # ---- geometry -------------------------------------------------------

    def _tkfont(self, size, bold=True):
        # Tk: positive size is points.  Used only for metrics; _font() is
        # what create_text gets, and must stay in the same units.
        pts = max(6, int(round(size * self.s)))
        key = (pts, bold)
        font = self._font_cache.get(key)
        if font is None:
            font = tkfont.Font(family="Helvetica", size=pts,
                               weight="bold" if bold else "normal")
            self._font_cache[key] = font
        return font

    def _font(self, size, bold=True):
        pts = max(6, int(round(size * self.s)))
        return ("Helvetica", pts, "bold" if bold else "normal")

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
        self.s = min(cw / float(REF_W), ch / float(REF_H))
        self.ox = (cw - REF_W * self.s) / 2.0
        self.oy = (ch - REF_H * self.s) / 2.0

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

    def _vtext(self, x, y, text, size=SETTING_SIZE, fill=C_INK):
        """Stacked caption.  Ascent plus a 2 px gutter — about 20% of the
        previous extra leading, so the letters stay separate without a
        large hole between them."""
        font = self._font(size)
        ascent = int(self._tkfont(size).metrics("ascent"))
        fh = ascent + 2
        chars = [ch for ch in text if not ch.isspace()]
        n = len(chars) or 1
        total = n * fh
        y0 = self.Y(y) - total / 2.0 + fh / 2.0
        cx = self.X(x)
        for i, ch in enumerate(chars):
            self.cv.create_text(cx, y0 + i * fh, text=ch, fill=fill,
                                font=font, anchor="c")

    def _rect(self, x1, y1, x2, y2, **kw):
        return self.cv.create_rectangle(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

    def _poly(self, pts, **kw):
        flat = []
        for x, y in pts:
            flat.extend(self.xy(x, y))
        return self.cv.create_polygon(flat, **kw)

    def _oval(self, x1, y1, x2, y2, **kw):
        return self.cv.create_oval(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

    def _vbar(self, cx, top, bot, width, fill, outline, width_px=1):
        """Vertical rounded-end bar.  Height must exceed width or it becomes a disc."""
        x1, x2 = cx - width / 2.0, cx + width / 2.0
        if bot < top:
            top, bot = bot, top
        h = bot - top
        w = width
        ow = max(1, int(width_px * self.s))
        if h <= w * 1.05:
            self._oval(x1, top, x2, bot, fill=fill, outline=outline, width=ow)
            return
        r = w / 2.0
        self._rect(x1, top + r, x2, bot - r, fill=fill, outline="", width=0)
        self._oval(x1, top, x2, top + w, fill=fill, outline="", width=0)
        self._oval(x1, bot - w, x2, bot, fill=fill, outline="", width=0)
        self._line(x1, top + r, x1, bot - r, fill=outline, width=ow)
        self._line(x2, top + r, x2, bot - r, fill=outline, width=ow)
        self.cv.create_arc(self.X(x1), self.Y(top), self.X(x2), self.Y(top + w),
                           start=0, extent=180, style="arc",
                           outline=outline, width=ow)
        self.cv.create_arc(self.X(x1), self.Y(bot - w), self.X(x2), self.Y(bot),
                           start=180, extent=180, style="arc",
                           outline=outline, width=ow)

    def _barberpole(self, x1, y1, x2, y2):
        px1, py1 = self.xy(x1, y1)
        px2, py2 = self.xy(x2, y2)
        w = max(2, int(abs(px2 - px1)))
        h = max(2, int(abs(py2 - py1)))
        key = (w, h)
        img = self._bp_cache.get(key)
        if img is None:
            img = tk.PhotoImage(width=w, height=h)
            pitch = max(4, w // 5)
            c1, c2 = "#f4f4f0", "#1a1a1a"
            for y in range(h):
                row = []
                for x in range(w):
                    row.append(c1 if ((x + y) // pitch) % 2 == 0 else c2)
                img.put("{" + " ".join(row) + "}", to=(0, y))
            self._bp_cache[key] = img
        self.cv.create_image(min(px1, px2), min(py1, py2),
                             image=img, anchor="nw")

    def _hit(self, kind, index, x1, y1, x2, y2):
        self._hits.append((kind, index,
                           self.X(x1), self.Y(y1),
                           self.X(x2), self.Y(y2)))

    # ---- the panel ------------------------------------------------------

    def _layout(self):
        """Even vertical rhythm.  Title-to-numbers is larger than the
        other gaps so a centered group name does not land on GPC 3."""
        g = 16          # divider / group-title leading
        tn = 24         # group title -> 1 2 3 4 5
        ns = 24         # numbers -> ON/BACKUP/RUN
        cap = 16        # setting caption -> control (and control -> caption)
        L = {}
        y = 46
        L["title"] = y
        y += 16
        L["title_line"] = y
        y += g

        L["power_title"] = y
        y += tn
        L["power_nums"] = y
        y += ns
        L["power_on"] = y
        y += cap
        L["power_sw"] = y
        y += 124 + cap
        L["power_off"] = y
        y += g + 6

        L["out_line"] = y
        y += g
        L["out_title"] = y
        y += g
        L["out_tb"] = y
        y += 34 + 12
        L["out_nums"] = y
        y += ns
        L["out_backup"] = y
        y += cap
        L["out_sw"] = y
        y += 136 + cap
        L["out_term"] = y
        y += g + 6

        L["ipl_line"] = y
        y += g
        L["ipl_title"] = y
        y += g
        L["ipl_btn"] = y
        y += 50 + g

        L["mode_tb"] = y
        y += 34 + 12
        L["mode_line"] = y
        y += g
        L["mode_title"] = y
        y += tn
        L["mode_nums"] = y
        y += ns
        L["mode_run"] = y
        y += cap
        L["mode_sw"] = y
        y += 116 + cap
        L["mode_halt"] = y
        return L

    def redraw(self):
        self._scale()
        self.cv.delete("all")
        self._hits = []
        self._bp_cache = {}
        L = self._layout()
        self.L = L

        # --- L-shaped outline, matching the SCOM figure ---
        # Main rectangle, plus a right-hand tab holding IPL SOURCE.
        mx0, my0 = 36, 28
        mx1, my1 = 668, 972
        ex1 = 790
        ey0 = L["out_backup"] - 10
        ey1 = L["mode_line"] + 4

        outline = [
            (mx0, my0), (mx1, my0), (mx1, ey0), (ex1, ey0),
            (ex1, ey1), (mx1, ey1), (mx1, my1), (mx0, my1),
        ]
        # Drop shadow
        shadow = [(x + 5, y + 6) for x, y in outline]
        self._poly(shadow, fill="#1a1a1a", outline="", width=0)
        self._poly(outline, fill=C_PANEL, outline=C_INK, width=max(2, int(2 * self.s)))
        # Bevel: light on top/left, dark on bottom/right.
        self._line(mx0, my0, mx1, my0, fill=C_PANEL_HI, width=max(2, int(2 * self.s)))
        self._line(mx0, my0, mx0, my1, fill=C_PANEL_HI, width=max(2, int(2 * self.s)))
        self._line(mx0, my1, mx1, my1, fill=C_PANEL_LO, width=max(2, int(2 * self.s)))
        self._line(mx1, ey1, mx1, my1, fill=C_PANEL_LO, width=max(1, int(self.s)))
        self._line(ex1, ey0, ex1, ey1, fill=C_PANEL_LO, width=max(2, int(2 * self.s)))
        self._line(mx1, ey1, ex1, ey1, fill=C_PANEL_LO, width=max(2, int(2 * self.s)))

        # Column centres for GPC 1..5 inside the main rectangle.
        inner_l, inner_r = 86, 630
        self.col = [inner_l + (inner_r - inner_l) * (i + 0.5) / N_GPC
                    for i in range(N_GPC)]
        self.col_w = (inner_r - inner_l) / N_GPC
        # Side captions sit the same distance from the control as on the
        # right: 14 px past the guard/hex edge, not against the panel rail.
        self.side_l_out = self.col[0] - 29 - 14
        self.side_r_out = self.col[-1] + 29 + 14
        self.side_l_mode = self.col[0] - 38 - 14
        self.side_r_mode = self.col[-1] + 38 + 14

        self._draw_title()
        self._draw_power()
        self._draw_output_talkbacks()
        self._draw_output_switches()
        self._draw_ipl()
        self._draw_mode_talkbacks()
        self._draw_mode_switches()
        self._draw_ipl_source(mx1, ex1, ey0, ey1)

    def _gpc_numbers(self, y):
        for i, cx in enumerate(self.col):
            self._text(cx, y, str(i + 1), size=12)

    def _draw_title(self):
        L = self.L
        self._text(347, L["title"], "GENERAL PURPOSE COMPUTER", size=13)
        self._line(70, L["title_line"], 624, L["title_line"],
                   fill=C_INK, width=max(1, int(self.s)))

    def _draw_power(self):
        L = self.L
        self._text(347, L["power_title"], "POWER", size=10)
        self._gpc_numbers(L["power_nums"])
        self._text(347, L["power_on"], "ON", size=SETTING_SIZE)

        guard_w, guard_h = 58, 124
        y1 = L["power_sw"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - guard_w / 2, cx + guard_w / 2
            y2 = y1 + guard_h
            pos = 0 if self.power[i] == "ON" else 1
            self._guarded_toggle(x1, y1, x2, y2, pos, npos=2)
            self._hit("power", i, x1, y1, x2, y2)

        self._text(347, L["power_off"], "OFF", size=SETTING_SIZE)

    def _draw_output_talkbacks(self):
        L = self.L
        self._line(70, L["out_line"], 624, L["out_line"],
                   fill=C_INK_DIM, width=1)
        self._text(347, L["out_title"], "OUTPUT", size=10)
        win_w, win_h = 50, 34
        y1 = L["out_tb"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - win_w / 2, cx + win_w / 2
            self._talkback(x1, y1, x2, y1 + win_h, self.output_tb(i))
            self._text(cx, L["out_nums"], str(i + 1), size=11)

    def _draw_output_switches(self):
        L = self.L
        self._text(347, L["out_backup"], "BACKUP", size=SETTING_SIZE)
        cy = L["out_sw"] + 68
        self._vtext(self.side_l_out, cy, "NORMAL")
        self._vtext(self.side_r_out, cy, "NORMAL")

        guard_w, guard_h = 58, 136
        y1 = L["out_sw"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - guard_w / 2, cx + guard_w / 2
            y2 = y1 + guard_h
            pos = OUTPUT_POS.index(self.output[i])
            self._guarded_toggle(x1, y1, x2, y2, pos, npos=3)
            self._hit("output", i, x1, y1, x2, y2)

        self._text(347, L["out_term"], "TERMINATE", size=SETTING_SIZE)

    def _draw_ipl(self):
        L = self.L
        self._line(70, L["ipl_line"], 624, L["ipl_line"],
                   fill=C_INK_DIM, width=1)
        self._text(347, L["ipl_title"], "INITIAL PROGRAM LOAD", size=10)
        btn = 50
        y1 = L["ipl_btn"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - btn / 2, cx + btn / 2
            self._pushbutton(x1, y1, x2, y1 + btn, str(i + 1), down=self.ipl[i])
            self._hit("ipl", i, x1, y1, x2, y1 + btn)

    def _draw_mode_talkbacks(self):
        L = self.L
        win_w, win_h = 50, 34
        y1 = L["mode_tb"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - win_w / 2, cx + win_w / 2
            self._talkback(x1, y1, x2, y1 + win_h, self.mode_tb(i),
                           legend_always="RUN")

    def _draw_mode_switches(self):
        L = self.L
        self._line(70, L["mode_line"], 624, L["mode_line"],
                   fill=C_INK_DIM, width=1)
        self._text(347, L["mode_title"], "MODE", size=10)
        self._gpc_numbers(L["mode_nums"])
        self._text(347, L["mode_run"], "RUN", size=SETTING_SIZE)

        rx, ry = 38, 58
        cy = L["mode_sw"] + ry
        self._vtext(self.side_l_mode, cy, "STBY")
        self._vtext(self.side_r_mode, cy, "STBY")
        for i, cx in enumerate(self.col):
            pos = MODE_POS.index(self.mode[i])
            self._hex_toggle(cx, cy, rx, ry, pos, npos=3)
            self._hit("mode", i, cx - rx, cy - ry, cx + rx, cy + ry)

        self._text(347, L["mode_halt"], "HALT", size=SETTING_SIZE)

    def _draw_ipl_source(self, mx1, ex1, ey0, ey1):
        cx = (mx1 + ex1) / 2.0
        self._text(cx, ey0 + 16, "IPL", size=9)
        self._text(cx, ey0 + 32, "SOURCE", size=9)
        self._text(cx, ey0 + 56, "MMU 1", size=SETTING_SIZE)

        gw, gh = 56, 140
        x1, y1 = cx - gw / 2, ey0 + 74
        x2, y2 = cx + gw / 2, ey0 + 74 + gh
        pos = IPL_SOURCE_POS.index(self.ipl_source)
        self._guarded_toggle(x1, y1, x2, y2, pos, npos=3)
        self._hit("ipl_source", None, x1, y1, x2, y2)

        self._text(cx, y2 + 16, "MMU 2", size=SETTING_SIZE)
        self._vtext(x2 + 14, (y1 + y2) / 2.0, "OFF")

    # ---- control bodies -------------------------------------------------

    def _guarded_toggle(self, x1, y1, x2, y2, pos, npos):
        """Rounded rectangular switch guard with a vertical paddle."""
        self._rect(x1, y1, x2, y2, fill=C_GUARD, outline=C_GUARD_LO,
                   width=max(2, int(1.5 * self.s)))
        m = 7
        self._rect(x1 + m, y1 + m, x2 - m, y2 - m,
                   fill=C_SLOT, outline="#111", width=1)
        self._draw_paddle(x1 + m, y1 + m, x2 - m, y2 - m, pos, npos)

    def _hex_toggle(self, cx, cy, rx, ry, pos, npos):
        """Lever-lock MODE switch, drawn as a pointy-top hexagon."""
        pts = []
        for k in range(6):
            a = math.radians(-90 + 60 * k)
            pts.append((cx + rx * math.cos(a), cy + ry * math.sin(a)))
        self._poly(pts, fill=C_GUARD, outline=C_GUARD_LO,
                   width=max(2, int(1.5 * self.s)))
        irx, iry = rx * 0.58, ry * 0.70
        ipt = []
        for k in range(6):
            a = math.radians(-90 + 60 * k)
            ipt.append((cx + irx * math.cos(a), cy + iry * math.sin(a)))
        self._poly(ipt, fill=C_SLOT, outline="#111", width=1)
        # Lever-lock tab, upper right — decorative, not a control.
        self._rect(cx + rx * 0.52, cy - ry * 0.18,
                   cx + rx * 0.90, cy + ry * 0.02,
                   fill=C_LOCK, outline=C_GUARD_LO, width=1)
        self._draw_paddle(cx - irx * 0.70, cy - iry * 0.78,
                          cx + irx * 0.70, cy + iry * 0.78,
                          pos, npos)

    def _draw_paddle(self, x1, y1, x2, y2, pos, npos):
        """White toggle paddle sitting at one of npos slots in a well."""
        well_h = y2 - y1
        well_w = x2 - x1
        # Narrow enough to stay a bar, not a disc, in every position.
        pw = well_w * 0.46
        ph = well_h * (0.50 if npos == 2 else 0.32)
        if ph < pw * 1.35:
            ph = pw * 1.35
            if ph > well_h * 0.62:
                ph = well_h * 0.62
        gap = max(3.0, well_h * 0.04)
        travel = max(0.0, well_h - ph - 2 * gap)
        t = pos / float(npos - 1) if npos > 1 else 0.0
        top = y1 + gap + t * travel
        bot = top + ph
        cx = (x1 + x2) / 2.0
        self._vbar(cx, top, bot, pw, C_PADDLE, C_PADDLE_LO, width_px=1)
        gx = cx
        gy1 = top + pw * 0.40
        gy2 = bot - pw * 0.40
        if gy2 > gy1 + 4:
            self._line(gx, gy1, gx, gy2, fill=C_PADDLE_GROOVE,
                       width=max(2, int(2 * self.s)))

    def _talkback(self, x1, y1, x2, y2, state, legend_always=None):
        """Electromechanical flag window: GRAY, BP, RUN, or IPL.

        legend_always is the word silk-screened on a MODE talkback in the
        SCOM figure ('RUN').  It is shown when the flag is in that state;
        barberpole / IPL replace it.
        """
        # Recessed bezel
        self._rect(x1 - 3, y1 - 3, x2 + 3, y2 + 3,
                   fill=C_BEZEL, outline="#1a1a1a",
                   width=max(1, int(self.s)))
        self._rect(x1, y1, x2, y2, fill=C_TB_GRAY, outline="#111", width=1)
        if state == "BP":
            self._barberpole(x1 + 1, y1 + 1, x2 - 1, y2 - 1)
        elif state == "GRAY":
            self._rect(x1 + 1, y1 + 1, x2 - 1, y2 - 1,
                       fill=C_TB_GRAY, outline="")
        else:
            # RUN or IPL flag
            self._rect(x1 + 1, y1 + 1, x2 - 1, y2 - 1,
                       fill=C_TB_LEGEND, outline="")
            word = state if state != "RUN" or legend_always is None else legend_always
            self._text((x1 + x2) / 2.0, (y1 + y2) / 2.0, word, size=10)

    def _pushbutton(self, x1, y1, x2, y2, label, down=False):
        fill = C_BTN_DOWN if down else C_BTN
        dx = 2 if down else 0
        # Bezel
        self._rect(x1, y1, x2, y2, fill=C_GUARD, outline=C_GUARD_LO,
                   width=max(2, int(1.5 * self.s)))
        m = 6
        self._rect(x1 + m + dx, y1 + m + dx, x2 - m + dx, y2 - m + dx,
                   fill=fill, outline=C_PADDLE_LO, width=1)
        self._text((x1 + x2) / 2.0 + dx, (y1 + y2) / 2.0 + dx,
                   label, size=14)

    # ---- mouse ----------------------------------------------------------

    def _find(self, x, y):
        for kind, index, x1, y1, x2, y2 in self._hits:
            if x1 <= x <= x2 and y1 <= y <= y2:
                return kind, index, x1, y1, x2, y2
        return None

    def _zone(self, y, y1, y2, npos):
        """Which of npos vertical slots was clicked?  0 = up."""
        if npos <= 1:
            return 0
        t = (y - y1) / float(y2 - y1) if y2 != y1 else 0.5
        t = 0.0 if t < 0 else 1.0 if t > 1 else t
        z = int(t * npos)
        return npos - 1 if z >= npos else z

    def _on_motion(self, event):
        hit = self._find(event.x, event.y)
        want = bool(hit)
        if want != self._cursor_hits:
            self._cursor_hits = want
            self.cv.configure(cursor="hand2" if want else "")

    def _on_press(self, event):
        hit = self._find(event.x, event.y)
        if hit is None:
            return
        kind, index, x1, y1, x2, y2 = hit
        if kind == "power":
            z = self._zone(event.y, y1, y2, 2)
            self._set_power(index, POWER_POS[z])
        elif kind == "output":
            z = self._zone(event.y, y1, y2, 3)
            self._set_output(index, OUTPUT_POS[z])
        elif kind == "mode":
            z = self._zone(event.y, y1, y2, 3)
            self._set_mode(index, MODE_POS[z])
        elif kind == "ipl_source":
            z = self._zone(event.y, y1, y2, 3)
            self._set_ipl_source(IPL_SOURCE_POS[z])
        elif kind == "ipl":
            self._set_ipl(index, True)
            self._held_ipl = index

    def _on_release(self, event):
        if self._held_ipl is not None:
            self._set_ipl(self._held_ipl, False)
            self._held_ipl = None

    def _set_power(self, i, value):
        old = self.power[i]
        self.power[i] = value
        self._announce("%s POWER" % GPCS[i], old, value)
        self.redraw()

    def _set_output(self, i, value):
        old = self.output[i]
        self.output[i] = value
        self._announce("%s OUTPUT" % GPCS[i], old, value)
        self.redraw()

    def _set_mode(self, i, value):
        old = self.mode[i]
        self.mode[i] = value
        self._announce("%s MODE" % GPCS[i], old, value)
        self.redraw()

    def _set_ipl(self, i, down):
        old = "ON" if self.ipl[i] else "OFF"
        new = "ON" if down else "OFF"
        self.ipl[i] = down
        self._announce("%s IPL" % GPCS[i], old, new)
        self.redraw()

    def _set_ipl_source(self, value):
        old = self.ipl_source
        self.ipl_source = value
        self._announce("IPL SOURCE", old, value)
        self.redraw()


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Space Shuttle panel O6 (GPC hardware controls)")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 780x980+80+40")
    args = ap.parse_args(argv)

    root = tk.Tk()
    panel = PanelO6(root)
    geom = args.geometry or os.environ.get("NSTS_O6_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("panelO6: bad --geometry %r: %s" % (geom, e))
    else:
        root.geometry("780x980")
    _dont_steal_focus(root)
    # Keep a reference so the panel is not collected; it owns no extra
    # threads, so Tk's mainloop is the whole process.
    root._panel = panel
    root.mainloop()


if __name__ == "__main__":
    main()
