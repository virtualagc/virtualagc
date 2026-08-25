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

MODE_SWITCH = [("HALT", 0), ("STANDBY", 1), ("RUN", 2), ("IPL", 3)]
IPL_SOURCE = [("MM1", 4), ("MM2", 5)]
OBSERVED_A = [("MM1 READY", 6), ("MM2 READY", 7)]
TOGGLES_A = [("IOP terminate A", 12), ("IOP terminate B", 13)]
TOGGLES_B = [("BFS engage 1", 3), ("BFS engage 2", 4), ("BFS engage 3", 5)]
CRT_SELECT = [("CRT select A", 6), ("CRT select B", 7)]

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


class Panel:
    def __init__(self, root):
        self.sock = D.sender()
        self.root = root
        root.title("GPC discretes")

        # What this panel drives.  Republished on a timer as well as on
        # change, because a discrete is a level and the bus has neither
        # delivery guarantees nor replay -- see discretes.py.
        self.mode = tk.IntVar(value=0)          # HALT at startup
        self.iplSource = tk.IntVar(value=4)     # MM1
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
        self._checks(f, D.REG_B, TOGGLES_B + CRT_SELECT)

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
                       for name, _ in TOGGLES_A + TOGGLES_B + CRT_SELECT)

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

    def _iplSourceChanged(self):
        chosen = self.iplSource.get()
        for _, bit in IPL_SOURCE:
            self._send(D.SET if bit == chosen else D.RESET,
                       D.REG_A, D.bit_mask(bit))

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
            owned = 0
            for _, b in MODE_SWITCH + IPL_SOURCE:
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


def main():
    root = tk.Tk()
    Panel(root)
    root.mainloop()


if __name__ == "__main__":
    main()
