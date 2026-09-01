#!/usr/bin/env python3
"""A crew panel for the GPC discrete inputs.

WHAT THIS IS FOR

A GPC's discrete inputs are hardware lines rather than bus traffic, and in
the simulation nothing drove them: every GPC came up holding a fixed
constant (GPC 1, IPL source MM1, MM1 ready, CRT 1).  Software that merely
samples a discrete never noticed, but software that HANDSHAKES on one
could not get past it -- FCMBOOT, the IPL bootstrap loader, waits for mass
memory READY to fall and rise again, and a line that is permanently ready
hangs it forever.

Discretes come from several places at once.  A mass memory drives its own
READY and needs no help from anybody.  The ones that come from a switch
need something to be the switch, and that is this: a panel of controls
that publishes set/reset bit messages on the discrete bus.

Run it beside gpc and mmu:

    python3 discretePanel.py

Nothing here is authoritative.  Any device may own any bit; this program
owns the ones a human would otherwise be flipping, and only watches the
rest.  Bits shown as OBSERVED are published by some other device -- the
panel displays their live state and does not drive them.

See discretes.py for the wire protocol, and com/discretes.coffee in
nsts-sim-gpc for the same protocol on the other side.
"""

import argparse
import os
import re
import subprocess
import threading
import tkinter as tk
from tkinter import ttk

import discretes as D

# The discrete map, from the IOP Principles of Operation as documented in
# gpc/iop.coffee and yaGPC2's src/iop.c.  IBM bit numbering, from the most
# significant end of the 32-bit register.
#
# Register A
#    0-3   HALT / STANDBY / RUN / IPL crew panel switches
#    4,5   MM1 / MM2 selected as the IPL source
#    6,7   MM1 / MM2 READY          <- the mass memory's own signal
#   12,13  IOP terminate A / B
# Register B
#    0-2   this GPC's own ID (1-5; 0 is not a legal ID)
#    3-5   BFS engage 1/2/3
#    6,7   CRT (display) select

# The MODE SWITCH proper is a three-position rotary: HALT / STANDBY / RUN.
#
# IPL (bit 3) is NOT a fourth position of it.  It is a separate momentary
# PUSHBUTTON, and it is live only while the mode switch stands in HALT --
# PASS User's Guide Table 2-2 puts "GPC to HALT mode" at step 4 and "GPC
# IPL - P/R" at step 10, with HALT still made.  So its bit is asserted ON
# TOP of HALT's rather than instead of it, and a panel that made IPL a
# fourth exclusive position could not express the real sequence at all.
MODE_SWITCH = [("HALT", 0), ("STANDBY", 1), ("RUN", 2)]
HALT_BIT = 0
IPL_BIT = 3
# The IPL SOURCE SELECT switch has THREE positions, not two.  Table 2-2
# step 3 selects a mass memory before the IPL, and step 14 -- "Mass Memory
# - IPL Source Select OFF" -- turns it back off afterwards, to remove the
# mask and let the software reach the MMU.  A two-position selector cannot
# be turned off, so it could not express step 14 at all.
#
# OFF drives neither bit, which is why it is a value no bit ever has.
IPL_SOURCE = [("MM1", 4), ("OFF", -1), ("MM2", 5)]
IPL_SOURCE_OFF = -1
OBSERVED_A = [("MM1 READY", 6), ("MM2 READY", 7)]
TOGGLES_A = [("IOP terminate A", 12), ("IOP terminate B", 13)]
# Register B's two composite fields, taken from the flight software's own
# masks rather than from either document -- the PASS User's Guide and the
# IOP Principles of Operation disagree about these, and the code does not.
# FCMDSCRM (GPC DISCRETE REDUNDANCY MANAGEMENT ROUTINE) declares:
#
#     FCMBEMKT EQU X'1C00'   BFS ENGAGE DISCRETE MASK(DIB)
#     FCMCSMK  EQU X'0300'   BFS CRT SELECT DISCRETE MASK(DIB)
#
# BFS ENGAGE is therefore ONE field of three bits (3,4,5), masked and tested
# as a unit -- which matches the PoO's own note that all three are "SET BY
# ORBITER BFS CONTROLLER WHEN BFS ENGAGE PUSH-BUTTON IS DEPRESSED".  It is
# one button, not three switches.
BFS_ENGAGE_BITS = (3, 4, 5)              # X'1C00'
#
# BFS CRT SELECT is a two-bit NUMBER, not a pair of flags.  FCMDSCRM does
#     NHI R3,FCMCSMK      ZERO ALL BITS EXCEPT BFS CRT SELECT
#     SRL R3,8            ALIGN BFS CRT SELECT IN BITS 14 AND 15
#     LH  R5,TDWASBT(R3)  GET GPC COUNT FOR SELECTED CRT
# -- shifting it down and using it as a TABLE INDEX.  FCMBUSCM reaches the
# same value from the other end (`ZRB R6,X'FFFC'` leaves the low two bits)
# and ARAGPCSW indexes ARAB_MASK_ARRAY with it, whose entries mask DK1/DK2/
# DK3 for 1/2/3.  So the field is the CRT number, and 0 means none selected
# -- the case GPCRTOPT's POLL45 ("IPL DEFAULT LOAD -- NO DEU SELECTED")
# exists to serve.  Bit 6 is the 2s place, bit 7 the 1s.
CRT_SELECT_BITS = (6, 7)                 # X'0300', bit 6 = 2s, bit 7 = 1s
CRT_SELECT = [("none", 0), ("CRT 1", 1), ("CRT 2", 2), ("CRT 3", 3)]

TOGGLES_B = []                           # register B has no lone switches

GPC_ID_BITS = (0, 1, 2)          # register B, a 3-bit field

# Bits that start made rather than broken.
#
# A panel is a panel whether or not anybody has touched it, so its resting
# position has to be the one the hardware is in -- otherwise merely running
# this program changes what the flight software sees.  That is not
# hypothetical: register B bits 6-7 are not two independent switches, they
# are the DEU_ID field.  GPCIPL reads them with `NHI R3,X'0300'` and treats
# zero as "there is no display unit" (MLIB80/GPCRTOPT.asm, POLL30: "IS THE
# DEU_ID 1, 2, 3, OR 4" / `LR R3,R3` / `BZ POLL45`), so publishing both bits
# broken told it there was no CRT to talk to, and it stopped looking for a
# display bus before it ever picked one.  Bit 7 alone is DEU_ID 1 -- CRT 1 --
# which is what a GPC with nothing driving it reads: yaGPC2's
# DISCRETE_IN_B_DEFAULT is 0x21000000, GPC 1 and CRT 1.
DEFAULT_ON = {(D.REG_B, 7)}


def _active_window():
    """The window the user is actually working in, as an X id string."""
    try:
        out = subprocess.run(["xprop", "-root", "_NET_ACTIVE_WINDOW"],
                             capture_output=True, text=True, timeout=5).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    m = re.search(r"(0x[0-9a-fA-F]+)", out)
    return m.group(1) if m and int(m.group(1), 16) else None


def _dont_steal_focus(root):
    """Map the panel without taking the keyboard away from the user.

    The panel is a crew panel: every control is a mouse control and it has no
    business receiving a keystroke.  Mapped the ordinary way it is a new
    top-level, so the window manager gives it the keyboard and whatever the
    user was typing elsewhere lands here -- silently, with the standard Tk
    class bindings ready to turn a space or an arrow key into a DISCRETE
    CHANGE.  That injects panel operations nobody performed into a test.

    Same two halves Don applied to MEDS (nsts-sim-gpc 852d01a, "meds: don't
    steal focus or Mod+Key's"), which used Electron's `show: false` +
    `showInactive()`.

    ASKING NICELY IS NOT ENOUGH.  EWMH says _NET_WM_USER_TIME 0 means "do not
    activate on map", and setting it while withdrawn was tried first -- the
    user reported the window still took focus.  Tk stamps its own timestamp
    when deiconify() maps the window, so the 0 does not survive.  So instead
    we note who had focus, map, and hand it straight back with wmctrl.  Both
    calls are best effort: no xprop/wmctrl, or a window manager that will not
    cooperate, and the second half below still stands.  (This desktop is
    Marco.)

    REFUSE THE KEYBOARD REGARDLESS.  takefocus=0 on every widget so Tk never
    gives one keyboard focus; keys then arrive at the toplevel and are
    swallowed.  This cannot be done with bind_all: the bindtag order is
    widget, class, toplevel, all, so the CLASS binding that makes space press
    a button has already run before "all" is reached.
    """
    def refuse(w):
        try:
            w.configure(takefocus=0)
        except tk.TclError:
            pass                                # frames and labels have none
        for child in w.winfo_children():
            refuse(child)
    refuse(root)
    root.bind("<Key>", lambda _e: "break")

    previous = _active_window()

    # Ask not to be activated in the first place.  EWMH: _NET_WM_USER_TIME 0
    # means "do not activate this window on map".  Set while withdrawn, so it
    # is in place before the map request.  Tk may stamp its own timestamp at
    # deiconify() and undo this -- which is why the restore below exists too;
    # the two are independent and neither is trusted alone.
    root.withdraw()
    root.update_idletasks()
    try:
        subprocess.run(["xprop", "-id", str(root.winfo_id()),
                        "-f", "_NET_WM_USER_TIME", "32c",
                        "-set", "_NET_WM_USER_TIME", "0"],
                       check=False, stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL, timeout=5)
    except (OSError, subprocess.SubprocessError):
        pass
    root.deiconify()

    def give_it_back():
        # No previous window means nothing was focused, so there is nothing
        # to steal and nothing to give back -- leave the panel focused.
        if not previous:
            return
        try:
            subprocess.run(["wmctrl", "-i", "-a", previous], check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                           timeout=5)
        except (OSError, subprocess.SubprocessError):
            pass
    # After the map has settled, or the WM re-focuses us right afterwards.
    root.after(400, give_it_back)


class Panel:
    def __init__(self, root):
        self.sock = D.sender()
        self.root = root
        root.title("GPC discretes")

        # What this panel drives.  Republished on a timer as well as on
        # change, because a discrete is a level and the bus has neither
        # delivery guarantees nor replay -- see discretes.py.
        self.mode = tk.IntVar(value=0)          # HALT at startup
        self.iplHeld = False                    # the IPL pushbutton, up
        self.iplSource = tk.IntVar(value=4)     # MM1
        # DEFAULT_ON put register B bit 7 up, which as a two-bit field is
        # CRT 1 -- the same resting value yaGPC2's own DISCRETE_IN_B_DEFAULT
        # (0x21000000, "GPC 1 and CRT 1") reports.
        self.crtSelect = tk.IntVar(value=1)
        self.bfsEngage = tk.BooleanVar(value=False)
        self.gpcId = tk.IntVar(value=1)
        self.toggles = {}                       # (reg, bit) -> BooleanVar

        # What other devices drive, shown but not published.
        self.observedA = 0
        self.observedVars = {}

        self._build()
        self._startListener()
        self._republish()

    # ---- UI -----------------------------------------------------------

    def _build(self):
        pad = {"padx": 8, "pady": 3}

        # One fixed-width font throughout.  The bit captions are meant to
        # line up in a column down the right of each group, and padding a
        # label to a fixed number of characters only does that when every
        # character is the same width.
        style = ttk.Style()
        for widget in ("TLabel", "TCheckbutton", "TRadiobutton", "TSpinbox",
                       "TEntry", "TLabelframe.Label"):
            style.configure(widget, font="TkFixedFont")

        # A column apiece, so each group's panes stack and a filler can take
        # up whatever is left.  Gridding the panes directly against each
        # other instead left bare window between the short pane in one
        # column and the tall one beside it, which reads as a hole rather
        # than as space.
        self.root.columnconfigure(0, weight=1)
        self.root.columnconfigure(1, weight=1)
        self.root.rowconfigure(0, weight=1)

        left = ttk.Frame(self.root)
        left.grid(row=0, column=0, sticky="nsew")
        right = ttk.Frame(self.root)
        right.grid(row=0, column=1, sticky="nsew")

        f = ttk.LabelFrame(left, text="GPC mode (panel O6)")
        f.pack(fill="x", **pad)
        for label, bit in MODE_SWITCH:
            ttk.Radiobutton(f, text=label, value=bit, variable=self.mode,
                            command=self._modeChanged).pack(anchor="w")

        f = ttk.LabelFrame(left, text="GPC IPL (panel O6)")
        f.pack(fill="x", **pad)
        # Momentary, and reported as "P/R" because that is what it is: the
        # bit is up while the button is down and drops when it is let go.
        self.iplButton = ttk.Button(f, text="IPL  P/R")
        self.iplButton.pack(anchor="w")
        self.iplButton.bind("<ButtonPress-1>", self._iplPressed)
        self.iplButton.bind("<ButtonRelease-1>", self._iplReleased)
        self._syncIplButton()

        f = ttk.LabelFrame(left, text="IPL source")
        f.pack(fill="x", **pad)
        for label, bit in IPL_SOURCE:
            ttk.Radiobutton(f, text=label, value=bit, variable=self.iplSource,
                            command=self._iplSourceChanged).pack(anchor="w")

        f = ttk.LabelFrame(left, text="This GPC")
        f.pack(fill="x", **pad)
        ttk.Label(f, text="GPC ID").pack(side="left")
        ttk.Spinbox(f, from_=1, to=5, width=4, textvariable=self.gpcId,
                    command=self._gpcIdChanged).pack(side="left", padx=6)

        # Untitled, and there to be looked past: it carries no control, it
        # just keeps the column the same surface as the rest of the panel.
        ttk.LabelFrame(left).pack(fill="both", expand=True, **pad)

        f = ttk.LabelFrame(right, text="Discrete inputs A")
        f.pack(fill="x", **pad)
        self._checks(f, D.REG_A, TOGGLES_A)

        ttk.LabelFrame(right).pack(fill="both", expand=True, **pad)

        f = ttk.LabelFrame(right, text="Discrete inputs B")
        f.pack(fill="x", **pad)
        ttk.Checkbutton(f, text="BFS engage        (bits 3-5)",
                        variable=self.bfsEngage,
                        command=self._bfsEngageChanged).pack(anchor="w")
        g = ttk.LabelFrame(f, text="BFC CRT select (bits 6-7)")
        g.pack(fill="x", pady=(6, 0))
        for label, value in CRT_SELECT:
            ttk.Radiobutton(g, text=label, value=value,
                            variable=self.crtSelect,
                            command=self._crtSelectChanged).pack(anchor="w")

        f = ttk.LabelFrame(self.root, text="Observed (driven by other devices)")
        f.grid(row=1, column=0, columnspan=2, sticky="ew", **pad)
        for label, bit in OBSERVED_A:
            v = tk.StringVar(value=self._observedText(label, None))
            self.observedVars[bit] = (v, label)
            ttk.Label(f, textvariable=v).pack(anchor="w")

        # In a pane of its own, spanning the width, so the panel ends on the
        # same edge it is built from rather than trailing off mid-sentence.
        f = ttk.LabelFrame(self.root)
        f.grid(row=2, column=0, columnspan=2, sticky="ew", **pad)
        self.status = tk.StringVar(value="Publishing on %s:%d every %d ms"
                                   % (D.GROUP, D.PORT, D.REPUBLISH_MS))
        ttk.Label(f, textvariable=self.status).pack(anchor="w", padx=4)

    # Widest label anywhere in either group, so the bit captions form one
    # column across both panes rather than two that nearly agree.
    _LABEL_WIDTH = max(len(name)
                       for name, _ in TOGGLES_A)

    def _checks(self, parent, reg, items):
        for label, bit in items:
            v = tk.BooleanVar(value=(reg, bit) in DEFAULT_ON)
            self.toggles[(reg, bit)] = v
            ttk.Checkbutton(
                parent,
                text="%-*s  (bit %2d)" % (self._LABEL_WIDTH, label, bit),
                variable=v,
                command=lambda r=reg, b=bit, var=v: self._toggle(r, b, var)
            ).pack(anchor="w")

    # ---- publishing ----------------------------------------------------

    def _send(self, op, reg, mask):
        D.publish(self.sock, op, reg, mask)

    def _toggle(self, reg, bit, var):
        self._send(D.SET if var.get() else D.RESET, reg, D.bit_mask(bit))

    def _modeChanged(self):
        # A rotary switch: exactly one position is made at a time, so the
        # others are explicitly broken rather than left to decay.
        chosen = self.mode.get()
        for _, bit in MODE_SWITCH:
            self._send(D.SET if bit == chosen else D.RESET,
                       D.REG_A, D.bit_mask(bit))
        # Leaving HALT drops the button with it: it cannot be held in.
        if chosen != HALT_BIT and self.iplHeld:
            self.iplHeld = False
        self._send(D.SET if self.iplHeld else D.RESET,
                   D.REG_A, D.bit_mask(IPL_BIT))
        self._syncIplButton()

    def _syncIplButton(self):
        """Pressable only in HALT, which is the only place it does anything."""
        state = "normal" if self.mode.get() == HALT_BIT else "disabled"
        self.iplButton.configure(state=state)

    def _iplPressed(self, _event=None):
        if self.mode.get() != HALT_BIT:
            return
        self.iplHeld = True
        self._send(D.SET, D.REG_A, D.bit_mask(IPL_BIT))

    def _iplReleased(self, _event=None):
        if not self.iplHeld:
            return
        self.iplHeld = False
        self._send(D.RESET, D.REG_A, D.bit_mask(IPL_BIT))

    def _iplSourceChanged(self):
        # OFF is not a bit, so it selects nothing and both are broken.
        chosen = self.iplSource.get()
        for _, bit in IPL_SOURCE:
            if bit == IPL_SOURCE_OFF:
                continue
            self._send(D.SET if bit == chosen else D.RESET,
                       D.REG_A, D.bit_mask(bit))

    def _sendField(self, reg, bits, value):
        """Drive a multi-bit field as one SET and one RESET.

        A field is not a row of switches: sending it a bit at a time walks
        the GPC through values the field never held.  The datagrams are the
        same ones as ever -- the mask has always been 32 bits wide -- they
        just carry the whole field.  Break before make, since "no bit set"
        is a value the hardware really does pass through.
        """
        on = off = 0
        for i, b in enumerate(bits):
            m = D.bit_mask(b)
            if value & (1 << (len(bits) - 1 - i)):
                on |= m
            else:
                off |= m
        if off:
            self._send(D.RESET, reg, off)
        if on:
            self._send(D.SET, reg, on)

    def _crtSelectChanged(self):
        self._sendField(D.REG_B, CRT_SELECT_BITS, self.crtSelect.get())

    def _bfsEngageChanged(self):
        # All three bits together: FCMDSCRM masks them as one field
        # (FCMBEMKT X'1C00'), and one push-button drives them.
        self._sendField(D.REG_B, BFS_ENGAGE_BITS,
                        0b111 if self.bfsEngage.get() else 0)

    def _gpcIdChanged(self):
        try:
            v = int(self.gpcId.get())
        except (ValueError, tk.TclError):
            return
        # A 3-bit field: set the ones, clear the zeros.  0 is not a legal
        # GPC ID -- a GPC reading it cannot identify itself -- so the
        # spinbox does not offer it.
        setMask = 0
        clrMask = 0
        for i, bit in enumerate(GPC_ID_BITS):
            if v & (1 << (len(GPC_ID_BITS) - 1 - i)):
                setMask |= D.bit_mask(bit)
            else:
                clrMask |= D.bit_mask(bit)
        if setMask:
            self._send(D.SET, D.REG_B, setMask)
        if clrMask:
            self._send(D.RESET, D.REG_B, clrMask)

    def _republish(self):
        """Re-assert every bit this panel owns."""
        self._modeChanged()
        self._iplSourceChanged()
        self._gpcIdChanged()
        self._crtSelectChanged()
        self._bfsEngageChanged()
        for (reg, bit), var in self.toggles.items():
            self._send(D.SET if var.get() else D.RESET, reg, D.bit_mask(bit))
        self.root.after(D.REPUBLISH_MS, self._republish)

    # ---- observing -----------------------------------------------------

    def _startListener(self):
        t = threading.Thread(target=self._listen, daemon=True)
        t.start()

    def _listen(self):
        sock = D.receiver()
        while True:
            try:
                data, _ = sock.recvfrom(2048)
            except OSError:
                return
            msg = D.decode(data)
            if msg is None or msg["reg"] != D.REG_A:
                continue
            # Only bits we do not drive ourselves are worth displaying;
            # our own republished traffic comes back to us too.
            owned = D.bit_mask(IPL_BIT)
            for _, b in MODE_SWITCH + IPL_SOURCE:
                if b != IPL_SOURCE_OFF:
                    owned |= D.bit_mask(b)
            for (reg, b) in self.toggles:
                if reg == D.REG_A:
                    owned |= D.bit_mask(b)
            if not (msg["mask"] & ~owned):
                continue
            self.observedA = D.apply(self.observedA, msg)
            self.root.after(0, self._refreshObserved)

    # None means nobody has driven the bit yet, which is not the same as
    # driving it low -- see discretes.py on staleness.
    @staticmethod
    def _observedText(label, on):
        state = "--" if on is None else ("ON" if on else "OFF")
        return "%-*s  %s" % (Panel._LABEL_WIDTH, label, state)

    def _refreshObserved(self):
        for bit, (var, label) in self.observedVars.items():
            var.set(self._observedText(
                label, bool(self.observedA & D.bit_mask(bit))))


# ---- scripted playback ------------------------------------------------
#
# The crew sequence is a SEQUENCE, not a state: HALT, then the IPL
# pushbutton pressed ON TOP OF HALT, then STANDBY, then RUN.  yaGPC2's
# --discrete-a/-b are static overrides and cannot express any of that --
# they assert a final state the software never transitioned into -- so a
# headless run could never reach the menu-selected load path.  The
# sequence belongs here, where the bit layout and the momentary-pushbutton
# semantics already live.
#
# Each line is `<milliseconds> <command>`, times measured from startup:
#
#     0     mode HALT
#     500   ipl                 (press and release, 250 ms apart)
#     3000  mode STANDBY
#     60000 mode RUN
#
# `source MM1|MM2|OFF` and `gpcid <n>` are also accepted.  Blank lines and
# `#` comments are ignored.
SCRIPT_HELP = "timed discrete sequence: '<ms> <command>' per line"
IPL_HOLD_MS = 250


def _parse_script(text):
    out = []
    for n, line in enumerate(text.splitlines(), 1):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split(None, 1)
        if len(parts) != 2 or not parts[0].isdigit():
            raise SystemExit(f"discretePanel: script line {n}: "
                             f"expected '<ms> <command>', got {line!r}")
        out.append((int(parts[0]), parts[1].strip()))
    return sorted(out, key=lambda e: e[0])


def _run_script(panel, entries, quitAfterMs=None):
    def do(cmd):
        verb, _, arg = cmd.partition(" ")
        arg = arg.strip()
        if verb == "mode":
            names = {n.upper(): b for n, b in MODE_SWITCH}
            if arg.upper() not in names:
                raise SystemExit(f"discretePanel: unknown mode {arg!r}")
            panel.mode.set(names[arg.upper()])
            panel._modeChanged()
        elif verb == "ipl":
            panel._iplPressed()
            panel.root.after(IPL_HOLD_MS, panel._iplReleased)
        elif verb == "source":
            names = {n.upper(): b for n, b in IPL_SOURCE}
            if arg.upper() not in names:
                raise SystemExit(f"discretePanel: unknown source {arg!r}")
            panel.iplSource.set(names[arg.upper()])
            panel._iplSourceChanged()
        elif verb == "bit":
            # `bit B 7 on` -- any bit this panel owns as a toggle, which is
            # how CRT select (register B bits 6-7, the DEU_ID field) is
            # reached.  Setting the variable rather than sending directly
            # matters: _republish re-asserts from the variables, so a direct
            # send would be undone on the next timer tick.
            reg, num, val = arg.split()
            key = (D.REG_A if reg.upper() == "A" else D.REG_B, int(num))
            on = val.lower() in ("on", "1", "set", "true")
            if key in panel.toggles:
                panel.toggles[key].set(on)
                panel._send(D.SET if on else D.RESET,
                            key[0], D.bit_mask(key[1]))
            elif key[0] == D.REG_B and key[1] in CRT_SELECT_BITS:
                # Part of the two-bit CRT SELECT field: fold the change into
                # the field's value so _republish agrees with it.  Bit 6 is
                # the 2s place, bit 7 the 1s.
                place = 1 << (len(CRT_SELECT_BITS) - 1
                              - CRT_SELECT_BITS.index(key[1]))
                v = panel.crtSelect.get()
                panel.crtSelect.set(v | place if on else v & ~place)
                panel._crtSelectChanged()
            elif key[0] == D.REG_B and key[1] in BFS_ENGAGE_BITS:
                panel.bfsEngage.set(on)
                panel._bfsEngageChanged()
            else:
                panel._send(D.SET if on else D.RESET,
                            key[0], D.bit_mask(key[1]))
        elif verb == "crt":
            # `crt 2` -- the BFC CRT SELECT field by number, 0 = none.
            panel.crtSelect.set(int(arg))
            panel._crtSelectChanged()
        elif verb == "bfsengage":
            panel.bfsEngage.set(arg.lower() in ("on", "1", "set", "true"))
            panel._bfsEngageChanged()
        elif verb == "gpcid":
            panel.gpcId.set(int(arg))
            panel._gpcIdChanged()
        else:
            raise SystemExit(f"discretePanel: unknown command {verb!r}")
        print(f"discretePanel: {cmd}", flush=True)

    for ms, cmd in entries:
        panel.root.after(ms, lambda c=cmd: do(c))
    if quitAfterMs is not None:
        panel.root.after(quitAfterMs, panel.root.quit)


def main():
    ap = argparse.ArgumentParser(description="GPC discrete panel")
    ap.add_argument("--script", metavar="FILE", help=SCRIPT_HELP)
    ap.add_argument("--quit-after", type=int, metavar="MS",
                    help="exit this many ms after startup (for scripted runs)")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry for the panel window, e.g. +1080+0 "
                         "(also NSTS_PANEL_GEOMETRY)")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range the buses use: bus n is "
                         "base+n and the discrete bus base+80 (default 6900, "
                         "matching busConfig).  Give a second emulation its "
                         "own base -- the same option on yaGPC2 and MEDS -- "
                         "to run it alongside the first without port "
                         "conflicts.  NSTS_BUS_PORT_BASE sets it too.")
    args = ap.parse_args()

    # Before any socket is opened.
    if args.port_base is not None:
        D.set_port_base(args.port_base)

    root = tk.Tk()
    panel = Panel(root)
    # --geometry places the window, so a rig that starts the panel beside two
    # MDU windows does not have to be dragged into shape every run.  Tk's own
    # spec, so "+1080+0" positions and "400x600+1080+0" sizes as well; the
    # environment variable is the same thing for callers that cannot easily add
    # an argument.
    geom = args.geometry or os.environ.get("NSTS_PANEL_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("discretePanel: bad --geometry %r: %s" % (geom, e))
    _dont_steal_focus(root)
    if args.script:
        with open(args.script) as f:
            _run_script(panel, _parse_script(f.read()), args.quit_after)
    root.mainloop()


if __name__ == "__main__":
    main()
