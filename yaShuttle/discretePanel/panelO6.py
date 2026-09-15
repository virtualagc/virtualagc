#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Visual simulation of Space Shuttle overhead panel O6 (paddle switches).

The GENERAL PURPOSE COMPUTER hardware controls live on panel O6, overhead
of the commander's seat.  This program draws that GPC half of the panel
(the MDM power switches on the left of the physical panel are not yet
included) and lets the controls be operated with the mouse.

It is also the crew panel on the GPC discrete bus, replacing
discretePanel.py: the same UDP multicast set/reset protocol (discretes.py),
the same 250 ms republishing, the same --script language.  EVERY column
drives its own GPC: each computer has its own discrete channel (port 6980
+ GPC ID), so all five columns publish, each on the channel of the GPC it
belongs to.  The per-GPC controls -- MODE, IPL, OUTPUT, BFC ENGAGE -- go
only to that column's computer; the shared IPL SOURCE, BFC CRT, BFC
DISENGAGE and RHC BFC ENGAGE controls are one wire feeding all five, and
are published to each.  --gpc-id names the column the log calls primary
and the channel this panel listens on for mass memory READY.  See "GPC
discrete inputs" below for the bit-by-bit mapping and where each part of
it comes from.

Control changes, and the discrete words they produce, are printed to
stdout.

The figure this layout follows is "GENERAL PURPOSE COMPUTER Hardware
Controls" in the Shuttle Crew Operations Manual (SCOM, USA007587 Rev A,
printed page 2.6-4).  Two rows of that figure are easy to misread:

  * The second row is not a set of slide switches.  Those hatched windows
    are the OUTPUT talkbacks: gray if that GPC may transmit on the
    flight-critical buses, barberpole if it may not.  They are driven by
    GPC output discretes, not by a crew switch of their own: here by each
    GPC's DO bit 7 (I/O ACTIVE TALKBACK), as yaGPC2 publishes it on that
    GPC's channel.  PASS sets it once in RUN.
  * The fifth row is the MODE talkback (RUN, IPL, or barberpole), not a
    control, and likewise driven by the GPC: IPL from DO bit 31 (IPL,
    hardware) while a bootstrap is in, RUN from DO bit 9 (RUN(READY)
    TALKBACK) once the GPC has initialised -- which, after an IPL, is how the
    crew knows the load is complete ("When the talkback goes to RUN, the IPL
    is complete", DPS Workbook USA005350 Rev B), even with the switch still
    in STBY -- and barberpole otherwise, or before the GPC is heard.  Each
    change is logged ("GPC2 MODE tb  BP -> RUN"), and a --script or
    simulatePASS --keys file can wait for one.

The OUTPUT switch itself is the third-row three-position toggle
(BACKUP / NORMAL / TERMINATE).  The MODE switch is the bottom-row
three-position toggle (RUN / STBY / HALT), lever-locked in RUN on the
real hardware; this simulation does not require pulling a lock.

To the right of O6 are the BFC CRT block from panel C3 (DISPLAY ON/OFF
and SELECT 1+2 / 2+3 / 3+1) and the BFC DISENGAGE block from panel F6
(a horizontal two-position toggle; RIGHT disengages the BFS).  Those
follow the highlighted insets on SCOM printed page 2.6-25.

Below the IPL SOURCE tab, in the same column, are two panes that are not
on any one crew panel.  RHC BFC ENGAGE holds the BFS ENGAGE pushbuttons
from the tops of the commander's and pilot's rotational hand controllers.
ACTIVITY has MM1 and MM2 lamps showing the mass memories' own READY
lines as heard on the bus: pane grey (OFF) until a unit's READY is first
heard, then green READY or red BUSY (READY dropped) for good.

To the right of those, a column of its own, are the IDP controls.  Panel
C2's inset (DPS Workbook USA005350 Rev B figure 2-31; Crew Software Interface
USA006083 Rev B sections 2.3-2.5): POWER and MAJ FUNC for IDP/CRT 1, 3 and 2,
in that order left to right, and below them the LEFT and RIGHT IDP/CRT SEL
switches, which say which IDP each forward keyboard talks to (left: 1 or 3;
right: 3 or 2).  Under C2 is panel O6's INTEGRATED DISPLAY PROCESSOR inset,
the four momentary LOAD switches, and under that IDP/CRT 4's POWER and MAJ
FUNC, which in the orbiter are beside the aft keyboard on panel R11 (Crew
Software Interface figure 2-3).  These go to the display processors, not to
the GPCs: see
"The IDP buses" below.

Usage:
    python3 panelO6.py
    python3 panelO6.py --size 512
    python3 panelO6.py --geometry 948x1250+80+20
    python3 panelO6.py --gpc-id 2 --port-base 7900
    python3 panelO6.py --script ipl.script --quit-after 60000
"""

import argparse
import os
import select
import socket
import struct
import subprocess
import threading
import time
import tkinter as tk
import tkinter.font as tkfont

import crewscript
import discretes as D

GPCS = ("GPC1", "GPC2", "GPC3", "GPC4", "GPC5")
N_GPC = 5

POWER_POS = ("ON", "OFF")          # up, down
OUTPUT_POS = ("BACKUP", "NORMAL", "TERMINATE")   # up, mid, down
MODE_POS = ("RUN", "STBY", "HALT")               # up, mid, down
IPL_SOURCE_POS = ("MMU 1", "OFF", "MMU 2")       # up, mid, down
BFC_DISPLAY_POS = ("ON", "OFF")                 # up, down
BFC_SELECT_POS = ("1+2", "2+3", "3+1")          # up, mid, down
BFC_DISENGAGE_POS = ("LEFT", "RIGHT")           # left, right; unlabeled
# The GPC discrete OUTPUT bits that drive O6's talkbacks (IBM numbering;
# SSSRC/BILDNEW5.asm's DO table).  Bit 7 is the I/O ACTIVE talkback.
DO_IO_ACTIVE_TB_BIT = 7
DO_READY_TB_BIT = 9
DO_IPL_TB_BIT = 31
IPL_TO_MODE_TB_GAP = 50  # = the IPL pushbutton's height
MMUS = ("MM1", "MM2")                           # ACTIVITY lamps, left to right
ACTIVITY_STATES = ("OFF", "READY", "BUSY")      # unpowered, green, red
RHCS = ("CDR", "PLT")                           # BFS ENGAGE pushbuttons

# Typical pre-flight: GPC 5 is the BFS computer, OUTPUT in BACKUP.  The
# GPCs start unpowered.  POWER drives no discrete -- the emulator is its own
# process -- so OFF only keeps the OUTPUT talkbacks barberpole.
DEFAULT_POWER = ["OFF"] * N_GPC
DEFAULT_OUTPUT = ["NORMAL", "NORMAL", "NORMAL", "NORMAL", "BACKUP"]
DEFAULT_MODE = ["HALT"] * N_GPC
DEFAULT_IPL_SOURCE = "OFF"
DEFAULT_BFC_DISPLAY = "OFF"
DEFAULT_BFC_SELECT = "1+2"
DEFAULT_BFC_DISENGAGE = "LEFT"     # RIGHT disengages the BFS
DEFAULT_ACTIVITY = ["OFF", "OFF"]
DEFAULT_GPC_ID = 1

# ---- The IDP buses ----------------------------------------------------------
#
# Panel C2 and the O6 IDP LOAD switches are wired to the display processors,
# which MEDS2.py simulates.  They talk to each IDP over its MDU <-> IDP bus,
# _IDPn: UDP multicast on the discrete bus's group, port base + 40 + n,
# big-endian 16-bit words, word 0 a tag.  These are MEDS2's MDU -> IDP tags
# (MDUMsg), the ones its IDP pane and simulatePASS's --keys tokens send; words
# 0xFF00 and up are IDP -> MDU traffic and are ignored here.
#
#     SET_MAJOR_FUNC 0x0001 [mf]    mf 0 PL, 1 GNC, 2 SM, 3 ILLEGAL
#     IDP_LOAD       0x0002         (MEDS2's DEU_LOAD); no words
#     IDP_POWER      0x0003 [on]    1 ON, 0 OFF
#     KYBD_SEL       0x0004 [mask]  bit 0: the LEFT keyboard talks to this
#                                   IDP; bit 1: the RIGHT keyboard does
#
# POWER and MAJ FUNC for IDPs 1-4, and KYBD_SEL for IDPs 1-3, are sent on
# every change and re-asserted every IDP_REPUBLISH_MS, as the discretes are: a
# late-starting MEDS2 gets them within a second.  LOAD goes once, when
# thrown.  And THE PANEL FOLLOWS THE BUS: the same messages from anyone else --
# a --keys token, a MEDS2 window's major function keys -- move the matching
# switch, so the re-assertion never fights them and the picture always shows
# what the IDPs were last told.
IDP_POWER_POS = ("ON", "OFF")                   # up, down
MAJ_FUNC_POS = ("GNC", "SM", "PL")              # up, mid, down
MF_NAMES = ("PL", "GNC", "SM", "ILLEGAL")       # MEDS2's major function values
LEFT_SEL_POS = ("1", "3")                       # left, right
RIGHT_SEL_POS = ("3", "2")                      # left, right
C2_IDPS = (1, 3, 2)                             # C2's sets, left to right
N_IDP_C2 = 3                                    # IDP 4's switches are on R11
N_IDP_SW = 4                                    # POWER and MAJ FUNC: C2's and R11's
N_IDP_LOAD = 4
IDP_BUS_OFFSET = 40
IDP_REPUBLISH_MS = 1000
ECHO_WINDOW_S = 0.5      # how long our own datagram's echo is waited for
TAG_SET_MAJOR_FUNC = 0x0001
TAG_IDP_LOAD = 0x0002
TAG_IDP_POWER = 0x0003
TAG_KYBD_SEL = 0x0004
DEFAULT_IDP_POWER = "OFF"
DEFAULT_LEFT_SEL = "1"
DEFAULT_RIGHT_SEL = "2"
MF_RING = "#c0201a"     # an ILLEGAL major function, as MEDS2's pane marks it


def default_major_func():
    """NSTS_MAJOR_FUNC, as MEDS2 reads it (0 PL, 1 GNC, 2 SM, 3 ILLEGAL);
    GNC without it."""
    v = os.environ.get("NSTS_MAJOR_FUNC", "")
    try:
        return int(v) & 3 if v.strip() else 1
    except ValueError:
        return 1


def idp_port(n):
    """IDP n's MDU <-> IDP bus, _IDPn."""
    return D.PORT_BASE + IDP_BUS_OFFSET + int(n)


def idp_receiver(n):
    """A socket subscribed to IDP n's bus, shared with MEDS2's own."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    except (AttributeError, OSError):
        pass
    s.bind(("", idp_port(n)))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s

# ---- GPC discrete inputs --------------------------------------------------
#
# The bus, wire format and bit map are discretePanel.py's and discretes.py's,
# which carry the reasoning for each field; this is where the controls on
# this panel land in them.  IBM bit numbering, from the most significant end
# of each 32-bit register.  The authority for which crew control drives
# which line is the BFS's own table of them, BFS.SRC/MLIB80/ENTRYS.asm
# ("DIA BIT 0=HALT CMD (FROM PANEL)" ... "13=I/O TERM B (FROM PANEL OR
# CNTLR)"), and for the BFC logic, DPS Familiarization Workbook (USA005351
# Rev C) sections 1.1.2, 8.2 and 13.2.
#
# Only the wired GPC's column is published.  The bus carries no GPC address,
# so every GPC listening on it reads the same lines; wiring a second one
# needs a protocol change, not just a second column.

# Register A.  The MODE switch is one field of three exclusive bits.  IPL is
# not a fourth position of it but a pushbutton that counts only in HALT.
MODE_BITS = {"HALT": 0, "STBY": 1, "RUN": 2}
IPL_BIT = 3
IPL_SOURCE_BITS = {"MMU 1": 4, "MMU 2": 5}       # OFF drives neither
MM_READY_BITS = (6, 7)                           # from the MMUs; observed
# I/O TERM A inhibits MIA channels 10-13 (PL1, PL2, LB1, LB2).  No crew
# control drives it: ENTRYS.asm has "12=I/O TERM A (FROM HDWR=0)" and
# "IO TERM A HARDWARE CONTROL (CLAMPED TO ZERO)", and PASS's self-test
# (MLIB80/STM0.asm) reports ERROR 129, "IOP TERMINATE SWITCH "A" IS ON", if
# it ever reads 1.  Held at 0; a --script can still set it.
TERM_A_BIT = 12
# I/O TERM B inhibits the flight-critical buses, channels 14-17 and 20-23.
# It is the BFC module's output, from this GPC's OUTPUT switch and the
# engage latches -- see PanelO6.term_b().
TERM_B_BIT = 13

# Register B.
GPC_ID_BITS = (0, 1, 2)                          # this GPC's ID, 1-5
BFS_ENGAGE_BITS = (3, 4, 5)                      # one field, all or none
# BFC CRT SELECT, a two-bit field with bit 6 the 2s place.  Workbook 8.2:
# with DISPLAY OFF "both discretes are off", so 0.  Each SELECT position sends
# the FIRST number of its legend: 1+2 sends 1, 2+3 sends 2, 3+1 sends 3.  The
# flight software says so twice.  ARAGPCSW.hal's ARAB_MASK_ARRAY, indexed by
# this value, hands BFS DK1/DK2/DK3 for 1/2/3 before engage and 1+2/2+3/3+1
# after; GPCIPL (GPCRTOPT.asm, CM4POLL) takes the value itself as the DEU to
# drive.  (A 2026-09-11 wiring of 2+3=1, 3+1=2, 1+2=3 is withdrawn.)
CRT_SELECT_BITS = (6, 7)
CRT_SELECT_VALUE = {"1+2": 1, "2+3": 2, "3+1": 3}


def _bits(bits):
    m = 0
    for b in bits:
        m |= D.bit_mask(b)
    return m


def _field(bits, value):
    """Mask for `value` in a field whose first bit is its most significant."""
    m = 0
    for i, b in enumerate(bits):
        if value & (1 << (len(bits) - 1 - i)):
            m |= D.bit_mask(b)
    return m


# Every bit this panel drives, re-asserted on each republish, 1 or 0.
OWNED_A = _bits(list(MODE_BITS.values()) + [IPL_BIT] +
                list(IPL_SOURCE_BITS.values()) + [TERM_A_BIT, TERM_B_BIT])
OWNED_B = _bits(GPC_ID_BITS + BFS_ENGAGE_BITS + CRT_SELECT_BITS)

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
C_WELL = "#d9d6cb"     # midway between the pane grey and the paddle cream
C_BEZEL = "#4a4840"
C_TB_GRAY = "#a3a39c"
C_TB_LEGEND = "#f2f0e6"
C_BTN = "#d5d2c6"
C_BTN_DOWN = "#8f8c80"
# ACTIVITY lamps.  Unpowered is the pane grey, so a dark lamp is just its rim.
C_LAMP = {"OFF": C_PANEL, "READY": "#1fbf2a", "BUSY": "#e02418"}# Tk reports no cap height, and its "ascent" is not one (on X11 with
# Nimbus Sans it nearly equals the caps; with Arial it is 1/4 taller).
# Advance widths are reliable, and the Helvetica metric family (Helvetica,
# Arial, Nimbus Sans, Liberation Sans) shares them: every digit is 0.556
# em, and caps are about 0.72 em.
HELV_DIGIT_EM = 0.556
HELV_CAP_EM = 0.72

# Window margin on every side equals the original top inset.
MARGIN = 28
PANE_GAP = 16          # air between O6 and the C3/F6 stack
C3_W = 236
C2_W = 720             # the IDP column: panel C2 over the O6 IDP LOAD inset
# ENGAGE pushbuttons.  Smaller than IPL's 50: at 50 the pane leaves only
# ~5 px under the IPL SOURCE tab at some --size values; at 40, 15 or more.
RHC_BTN = 40
O6_MAIN_RIGHT = 668    # right edge of the O6 main rectangle (IPL tab is below C3/F6)
REF_W = O6_MAIN_RIGHT + PANE_GAP + C3_W + PANE_GAP + C2_W + MARGIN   # 1684
REF_H = 1300           # 1250 before the IPL-to-talkback gap was added
FULL_SIZE = 768        # --size units: 768 is the design (full) window

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


def _dont_steal_focus(root, mapWindow=True):
    """Map without taking the keyboard.  Best-effort; see discretePanel.py.

    mapWindow=False never maps the window at all, which is what a scripted
    run wants: nobody is looking, and a window that is never mapped cannot
    take the keyboard even for the 400 ms the hand-back below needs.
    """

    def refuse(w):
        try:
            w.configure(takefocus=0)
        except tk.TclError:
            pass
        for child in w.winfo_children():
            refuse(child)

    refuse(root)
    root.bind("<Key>", lambda _e: "break")
    if not mapWindow:
        root.withdraw()
        return
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


class PanelO6:
    def __init__(self, root, size=FULL_SIZE, gpc_id=DEFAULT_GPC_ID):
        self.root = root
        root.title("Panels O6, C3, F6, C2, R11  —  GPC / BFC / IDP")
        root.configure(bg=C_WINDOW)
        mw, mh = scaled_wh(640, 700, size)
        root.minsize(mw, mh)

        self.power = list(DEFAULT_POWER)
        self.output = list(DEFAULT_OUTPUT)
        self.ipl = [False] * N_GPC
        self.mode = list(DEFAULT_MODE)
        self.ipl_source = DEFAULT_IPL_SOURCE
        self.bfc_display = DEFAULT_BFC_DISPLAY
        self.bfc_select = DEFAULT_BFC_SELECT
        self.bfc_disengage = DEFAULT_BFC_DISENGAGE
        self.activity = list(DEFAULT_ACTIVITY)
        self.rhc = [False] * len(RHCS)       # ENGAGE pushbuttons, held down
        self.latch = [False] * N_GPC         # each GPC's BFC engage latches
        self.term_a = False                  # hardware 0; --script only
        self.wired = gpc_id - 1              # the column that is published
        self._held = None                    # (kind, index) of a held button
        self._user_wait = None               # done() for a script's 'wait user'
        # The IDP controls, indexed by IDP number - 1.
        self.idp_power = [DEFAULT_IDP_POWER] * N_IDP_SW
        self.idp_mf = [default_major_func()] * N_IDP_SW
        self.kybd_sel = {"left": DEFAULT_LEFT_SEL, "right": DEFAULT_RIGHT_SEL}
        self.idp_load = [False] * N_IDP_LOAD
        # Each GPC's own discrete OUTPUT register, as yaGPC2 publishes it on
        # that GPC's channel: None until heard.  The O6 talkbacks are driven
        # from these bits -- see mode_tb().
        self.gpc_out = [None] * N_GPC
        self._tb_shown = ["BP"] * N_GPC
        self._out_tb_shown = ["BP"] * N_GPC

        cw, ch = scaled_wh(REF_W, REF_H, size)
        self.cv = tk.Canvas(root, bg=C_WINDOW, highlightthickness=0,
                            width=cw, height=ch)
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
        self.cv.bind("<Leave>", self._on_leave)

        self._dump_state("startup")

        # The discrete bus.  Published on every change and re-asserted every
        # REPUBLISH_MS, because a discrete is a level and the bus is UDP with
        # no replay for a late joiner -- see discretes.py.
        self.sock = D.sender()
        self._published = None
        self._send_failed = False
        # THE BUS IS SERVED FROM ITS OWN THREAD.  The Tk thread waits on the X
        # server whenever it draws, and a saturated X server (Xorg pegged at a
        # full core) kept it from re-asserting for more than yaGPC2's 1.5 s
        # staleness limit -- which held every running GPC at once and broke
        # their common set (yaGPC2 ledger #147, run heldrep).  So the Tk side
        # only says WHAT to publish (_publish) and _pub_loop does ALL the
        # sending, which also keeps each RESET/SET pair in order.
        self._pub_lock = threading.Lock()
        self._pub_columns = None
        self._pub_wake = threading.Event()
        self._tick_last = None
        threading.Thread(target=self._pub_loop, daemon=True).start()
        # NSTS_PANEL_STALL=<start s>,<seconds>: A TEST OF _pub_loop.  One tick
        # holds the Tk thread that long, as a busy X server would.
        stall = os.environ.get("NSTS_PANEL_STALL", "")
        try:
            a, b = stall.split(",")
            self._stall = (time.monotonic() + float(a), float(b))
        except ValueError:
            self._stall = None
        log("publishing all %d GPCs' discretes on %s:%d-%d every %d ms"
            % (N_GPC, D.GROUP, D.gpc_port(1), D.gpc_port(N_GPC),
               D.REPUBLISH_MS))
        # Mass memory READY, heard by a listener thread and picked up on the
        # Tk side by _tick(): the last level per unit, or None if never.
        self._rx_lock = threading.Lock()
        self._mm_heard = [None] * len(MM_READY_BITS)
        threading.Thread(target=self._listen, daemon=True).start()
        threading.Thread(target=self._listen_out, daemon=True).start()
        # The IDP buses; see "The IDP buses" above.  What the listener hears
        # waits in _idp_rx for the Tk side; what we sent waits in _idp_sent
        # so that its own echo is not mistaken for someone else's command.
        self.idp_sock = D.sender()
        self._idp_rx = []
        self._idp_sent = []
        self._idp_send_failed = False
        log("IDP controls on %s:%d-%d, re-asserted every %d ms"
            % (D.GROUP, idp_port(1), idp_port(N_IDP_LOAD), IDP_REPUBLISH_MS))
        # Bound here, before the first publish, so that publish's own echo
        # is heard and struck off rather than left to eat a later command.
        self._idp_socks = {}
        for n in range(1, N_IDP_SW + 1):
            try:
                self._idp_socks[idp_receiver(n)] = n
            except OSError as e:
                log("cannot listen on IDP%d's bus: %s" % (n, e))
        threading.Thread(target=self._listen_idp, daemon=True).start()
        self._idp_publish()
        self.root.after(IDP_REPUBLISH_MS, self._idp_tick)
        self._tick()

    # ---- the BFC modules --------------------------------------------------
    #
    # Workbook 13.2.1.  The OUTPUT switches set two inputs of each GPC's BFC
    # module: BFC GPC SELECT and BFC SELECT OFF.  An ENGAGE pushbutton sets
    # the module's latches unless SELECT OFF or the F6 DISENGAGE switch is
    # clearing them; the latches are the GPC's three ENGAGE discretes, and
    # I/O TERM B is the latches EXCLUSIVE-OR BFC GPC SELECT.  So before an
    # engage a PASS GPC in NORMAL may transmit and the BFS in BACKUP may not,
    # after one it is the other way round, and a GPC in TERMINATE never may.
    # The workbook's three contacts per button and "3 of 3" voting guard
    # against failed electronics, which are not simulated, so one latch per
    # module stands for all six.

    def _backup_gpc(self):
        """Only the highest-numbered GPC in BACKUP is the BFS GPC."""
        for i in reversed(range(N_GPC)):
            if self.output[i] == "BACKUP":
                return i
        return None

    def _bfc_gpc_select(self, i):
        return self.output[i] == "TERMINATE" or i == self._backup_gpc()

    def _bfc_select_off(self, i):
        # "whenever all GPCs are in NORMAL or TERMINATE", and for a GPC in
        # TERMINATE -- so there is no engage with no BFS to engage.
        return self.output[i] == "TERMINATE" or self._backup_gpc() is None

    def _update_latches(self):
        before = list(self.latch)
        disengage = self.bfc_disengage == "RIGHT"
        pressed = any(self.rhc)
        for i in range(N_GPC):
            if disengage or self._bfc_select_off(i):
                self.latch[i] = False
            elif pressed:
                self.latch[i] = True
        if self.latch != before:
            on = [GPCS[i] for i in range(N_GPC) if self.latch[i]]
            log("BFC ENGAGE latches  %s" % (" ".join(on) if on else "clear"))

    def term_b(self, i):
        return self.latch[i] != self._bfc_gpc_select(i)

    # ---- talkbacks: driven by each GPC's discrete outputs ------------------

    def output_tb(self, i):
        """GRAY when the GPC can command the flight-critical buses, else BP.

        DPS Workbook (USA005350 Rev B) 2.x: "A discrete output from the GPC
        drives the talkback to gray if output is enabled, and the talkback
        goes barberpole (bp) if it is not (I/O TERM B set or the GPC not in
        RUN)."  That output is DO bit 7, I/O ACTIVE TALKBACK; yaGPC2 run
        verify-tb saw PASS set it 2.4 s after the switch reached RUN."""
        out = self.gpc_out[i]
        if out is not None and out & D.bit_mask(DO_IO_ACTIVE_TB_BIT):
            return "GRAY"
        return "BP"

    def _ipl_live(self, i):
        """The IPL pushbutton does something only in HALT."""
        return self.ipl[i] and self.mode[i] == "HALT"

    def mode_tb(self, i):
        """RUN, IPL or barberpole, driven by the GPC, not by the switch.

        DPS Workbook (USA005350 Rev B) 2.x: the OUTPUT and MODE talkbacks "are
        driven directly from GPC output discretes"; 3.x: "The MODE talkback
        goes to IPL while the initialization software is loaded ... When the
        talkback goes to RUN, the IPL is complete."  The bits are the GPC's DO
        register (SSSRC/BILDNEW5.asm): 9 RUN(READY) TALKBACK, which FCMSWMON
        sets when the load is complete, and 31 IPL (HDWR).  A GPC nobody has
        heard from is barberpole, as an unpowered one is."""
        out = self.gpc_out[i]
        if out is None:
            return "BP"
        if out & D.bit_mask(DO_IPL_TB_BIT):
            return "IPL"
        if out & D.bit_mask(DO_READY_TB_BIT):
            return "RUN"
        return "BP"

    def _dump_state(self, why):
        log(why)
        for i, name in enumerate(GPCS):
            log("  %s  POWER=%-3s  OUTPUT=%-9s  MODE=%-4s  IPL=%s  "
                "OUT-tb=%s  MODE-tb=%s%s"
                % (name, self.power[i], self.output[i], self.mode[i],
                   "ON" if self.ipl[i] else "OFF",
                   self.output_tb(i), self.mode_tb(i),
                   "  (primary)" if i == self.wired else ""))
        log("  IPL SOURCE=%s" % self.ipl_source)
        log("  BFC CRT DISPLAY=%s  SELECT=%s" %
            (self.bfc_display, self.bfc_select))
        log("  BFC DISENGAGE=%s" % self.bfc_disengage)
        log("  RHC BFC ENGAGE  %s" % "  ".join(
            "%s=%s" % (r, "ON" if h else "OFF") for r, h in zip(RHCS, self.rhc)))
        log("  ACTIVITY  %s" % "  ".join(
            "%s=%s" % (m, a) for m, a in zip(MMUS, self.activity)))
        for n in list(C2_IDPS) + [4]:
            log("  IDP/CRT %d  POWER=%s  MAJ FUNC=%s"
                % (n, self.idp_power[n - 1], MF_NAMES[self.idp_mf[n - 1]]))
        log("  IDP/CRT SEL  LEFT=%s  RIGHT=%s"
            % (self.kybd_sel["left"], self.kybd_sel["right"]))

    # ---- the discrete bus -------------------------------------------------

    def discretes(self, w=None):
        """Registers A and B as the GPC in column `w` should read them.

        Defaults to the highlighted column.  Each computer has its own
        discrete channel, so every column is published on its own -- the
        per-GPC state (mode, IPL, BFC latch, I/O TERMINATE B) differs by
        column, while the panel-wide switches (IPL SOURCE, I/O TERMINATE A,
        the BFC CRT select) are the same wire feeding all five.

        Only the OWNED_A / OWNED_B bits mean anything; the rest belong to
        other devices.
        """
        if w is None:
            w = self.wired
        a = D.bit_mask(MODE_BITS[self.mode[w]])
        if self._ipl_live(w):
            a |= D.bit_mask(IPL_BIT)
        if self.ipl_source in IPL_SOURCE_BITS:
            a |= D.bit_mask(IPL_SOURCE_BITS[self.ipl_source])
        if self.term_a:
            a |= D.bit_mask(TERM_A_BIT)
        if self.term_b(w):
            a |= D.bit_mask(TERM_B_BIT)
        b = _field(GPC_ID_BITS, w + 1)
        if self.latch[w]:
            b |= _field(BFS_ENGAGE_BITS, 0b111)
        b |= _field(CRT_SELECT_BITS, self.crt_value())
        return a, b

    def crt_value(self):
        if self.bfc_display != "ON":
            return 0
        return CRT_SELECT_VALUE[self.bfc_select]

    def _publish(self):
        """Hand every column's discretes to _pub_loop, and wake it."""
        columns = [self.discretes(w) for w in range(N_GPC)]
        with self._pub_lock:
            self._pub_columns = columns
        self._pub_wake.set()
        if columns != self._published:
            for w, (a, b) in enumerate(columns):
                if self._published is None or self._published[w] != (a, b):
                    log("%s discretes  A=%08x  B=%08x"
                        % (GPCS[w], a & OWNED_A, b & OWNED_B))
            self._published = columns

    def _pub_loop(self):
        """Thread: assert every owned bit, one RESET then one SET per register,
        at once on a change and every REPUBLISH_MS regardless.

        Break before make, as discretePanel.py's _sendField: a field changing
        value passes through "no bit set", which the hardware does too, and
        never through a value it did not hold.
        """
        period = D.REPUBLISH_MS / 1000.0
        while True:
            self._pub_wake.wait(period)
            self._pub_wake.clear()
            with self._pub_lock:
                columns = self._pub_columns
            if columns is None:
                continue
            try:
                for w, (a, b) in enumerate(columns):
                    port = D.gpc_port(w + 1)
                    for reg, owned, value in ((D.REG_A, OWNED_A, a),
                                              (D.REG_B, OWNED_B, b)):
                        if owned & ~value:
                            D.publish(self.sock, D.RESET, reg, owned & ~value,
                                      port=port)
                        if owned & value:
                            D.publish(self.sock, D.SET, reg, owned & value,
                                      port=port)
                self._send_failed = False
            except OSError as e:
                if not self._send_failed:
                    log("cannot publish on the discrete bus: %s" % e)
                self._send_failed = True

    def _listen(self):
        """Thread: note every MM READY level anybody publishes."""
        try:
            sock = D.receiver()
        except OSError as e:
            log("cannot listen on the discrete bus: %s" % e)
            return
        while True:
            try:
                data, _ = sock.recvfrom(2048)
            except OSError:
                return
            msg = D.decode(data)
            if msg is None or msg["reg"] != D.REG_A:
                continue
            with self._rx_lock:
                for u, bit in enumerate(MM_READY_BITS):
                    if msg["mask"] & D.bit_mask(bit):
                        self._mm_heard[u] = msg["op"] == D.SET

    def _listen_out(self):
        """Thread: every GPC's discrete OUTPUT register, on its own channel.

        The panel's own channel hears only the primary GPC, and _listen keeps
        only register A, so the talkbacks need a socket per computer.  A
        REQUEST asks each GPC for its whole register, so a panel started after
        the computers still shows what they are driving."""
        socks = {}
        for n in range(1, N_GPC + 1):
            port = D.gpc_port(n)
            try:
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM,
                                  socket.IPPROTO_UDP)
                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
                s.bind(("", port))
                s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                             struct.pack("4s4s", socket.inet_aton(D.GROUP),
                                         socket.inet_aton(D.IFACE)))
            except OSError as e:
                log("cannot listen for GPC%d's discrete outputs: %s" % (n, e))
                continue
            socks[s] = n - 1
            try:
                D.publish(self.sock, D.REQUEST, D.REG_OUT, 0, port=port)
            except OSError:
                pass
        while socks:
            try:
                ready, _, _ = select.select(list(socks), [], [], 1.0)
            except (OSError, ValueError):
                return
            for s in ready:
                try:
                    data, _ = s.recvfrom(2048)
                except OSError:
                    continue
                msg = D.decode(data)
                if (msg is None or msg["reg"] != D.REG_OUT
                        or msg["op"] == D.REQUEST):
                    continue
                i = socks[s]
                with self._rx_lock:
                    self.gpc_out[i] = D.apply(self.gpc_out[i] or 0, msg)

    def _talkbacks_follow(self):
        """Tk side: log and redraw a talkback when its GPC moves it."""
        changed = False
        for i in range(N_GPC):
            now = self.mode_tb(i)
            if now != self._tb_shown[i]:
                log("%s MODE tb  %s -> %s" % (GPCS[i], self._tb_shown[i], now))
                self._tb_shown[i] = now
                changed = True
            now = self.output_tb(i)
            if now != self._out_tb_shown[i]:
                log("%s OUTPUT tb  %s -> %s" % (GPCS[i], self._out_tb_shown[i], now))
                self._out_tb_shown[i] = now
                changed = True
        if changed:
            self.redraw()

    def _tick(self):
        """Every REPUBLISH_MS: re-assert our bits, refresh the lamps.

        A lamp is OFF until its unit's READY is first heard, and READY or
        BUSY from then on -- a unit that goes quiet keeps its last state.
        """
        # How late is the Tk thread?  Only a tick well past its period is
        # logged; _pub_loop keeps the bus up meanwhile.
        now = time.monotonic()
        if self._tick_last is not None:
            late = (now - self._tick_last) * 1000.0 - D.REPUBLISH_MS
            if late > 200:
                log("Tk tick %.0f ms late (the discrete bus is republished "
                    "by its own thread)" % late)
        if self._stall is not None and now >= self._stall[0]:
            log("NSTS_PANEL_STALL: holding the Tk thread %.1f s" % self._stall[1])
            time.sleep(self._stall[1])
            self._stall = None
            now = time.monotonic()
        self._tick_last = now
        self._talkbacks_follow()
        self._idp_adopt()
        with self._rx_lock:
            heard = list(self._mm_heard)
        for u, h in enumerate(heard):
            if h is None:
                state = "OFF"
            else:
                state = "READY" if h else "BUSY"
            if state != self.activity[u]:
                self.set_activity(u, state)
        self._publish()
        self.root.after(D.REPUBLISH_MS, self._tick)

    def _changed(self):
        """After any control moves: BFC logic, bus, picture."""
        self._update_latches()
        self._publish()
        self.redraw()

    def _announce(self, what, old, new):
        if old == new:
            return
        log("%s  %s -> %s" % (what, old, new))

    # ---- geometry -------------------------------------------------------

    def _tkfont(self, size, bold=True):
        # Tk: positive size is points.  Used only for metrics; _font() is
        # what create_text gets, and must stay in the same units.
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
        """Half-height of a centre-anchored caption, in reference coords.

        Layout y values are the centres of the glyphs.  Neighbouring
        objects have to clear this plus PAD, or the ink collides.
        """
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

    def _poly(self, pts, **kw):
        flat = []
        for x, y in pts:
            flat.extend(self.xy(x, y))
        return self.cv.create_polygon(flat, **kw)

    def _oval(self, x1, y1, x2, y2, **kw):
        return self.cv.create_oval(
            self.X(x1), self.Y(y1), self.X(x2), self.Y(y2), **kw)

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
        """Vertical rhythm from glyph bounds, not from centre-to-centre
        steps.  PAD is empty air above and below every caption; without
        it the linespace is the whole gap and the letters sit on the
        controls (the OUTPUT 1..5 row was the worst case)."""
        pad = 10
        bezel = 4          # talkback/button outline outside the content box
        th13 = self._th(13)
        th12 = self._th(12)
        th11 = self._th(11)
        th10 = self._th(10)
        ths = self._th(SETTING_SIZE)
        L = {}
        y = 28 + pad

        y += th13
        L["title"] = y
        y += th13 + pad
        L["title_line"] = y
        y += pad

        y += th10
        L["power_title"] = y
        y += th10 + pad
        y += th12
        L["power_nums"] = y
        y += th12 + pad
        y += ths
        L["power_on"] = y
        y += ths + pad
        L["power_sw"] = y
        y += 124 + pad
        y += ths
        L["power_off"] = y
        y += ths + pad

        y += pad
        L["out_line"] = y
        y += pad
        y += th10
        L["out_title"] = y
        y += th10 + pad
        L["out_tb"] = y
        y += 34 + bezel + pad
        y += th11
        L["out_nums"] = y
        y += th11 + pad
        y += ths
        L["out_backup"] = y
        y += ths + pad
        L["out_sw"] = y
        y += 136 + pad
        y += ths
        L["out_term"] = y
        y += ths + pad

        y += pad
        L["ipl_line"] = y
        y += pad
        y += th10
        L["ipl_title"] = y
        y += th10 + pad
        L["ipl_btn"] = y
        y += 50 + bezel + pad
        # About one pushbutton's height of air before the MODE talkbacks
        # (owner, 2026-09-15): they report what the GPC is doing, not the
        # state of the IPL button above them, and sat too close to read so.
        y += IPL_TO_MODE_TB_GAP

        L["mode_tb"] = y
        y += 34 + bezel + pad
        y += pad
        L["mode_line"] = y
        y += pad
        y += th10
        L["mode_title"] = y
        y += th10 + pad
        y += th12
        L["mode_nums"] = y
        y += th12 + pad
        y += ths
        L["mode_run"] = y
        y += ths + pad
        L["mode_sw"] = y
        y += 136 + pad
        y += ths
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
        mx0, my0 = MARGIN, MARGIN
        mx1 = O6_MAIN_RIGHT
        my1 = L["mode_halt"] + 24
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
        self.mid = self.col[2]          # GPC3, where setting captions sit
        # Side captions sit the same distance from the control as on the
        # right: 14 px past the guard edge, not against the panel rail.
        self.side_l_out = self.col[0] - 29 - 14
        self.side_r_out = self.col[-1] + 29 + 14

        self._draw_title()
        self._draw_power()
        self._draw_output_talkbacks()
        self._draw_output_switches()
        self._draw_ipl()
        self._draw_mode_talkbacks()
        self._draw_mode_switches()
        self._draw_ipl_source(mx1, ex1, ey0, ey1)

        # C3 / F6 sit in the O6 concave cutout, above the IPL SOURCE tab.
        pad = 10
        th10 = self._th(10)
        ths = self._th(SETTING_SIZE)
        c3_sw_h = 136          # same 3-pos guard as O6 OUTPUT
        sw_h = 58              # F6 is POWER's 58x124 guard, rotated
        c3_x0 = mx1 + PANE_GAP
        c3_x1 = c3_x0 + C3_W
        c3_y0 = my0
        # Heights follow _draw_c3 / _draw_f6: centre-anchored titles
        # consume a full linespace on each side of the glyph.
        c3_y1 = c3_y0 + 5 * pad + 2 * th10 + 6 * ths + c3_sw_h
        f6_x0, f6_x1 = c3_x0, c3_x1
        f6_y0 = c3_y1 + PANE_GAP
        f6_y1 = f6_y0 + 4 * pad + 4 * th10 + sw_h
        self._draw_c3(c3_x0, c3_y0, c3_x1, c3_y1)
        self._draw_f6(f6_x0, f6_y0, f6_x1, f6_y1)
        # Below the IPL SOURCE tab, in the same column: ACTIVITY with its
        # bottom on O6's bottom edge, and RHC BFC ENGAGE directly above it.
        # Heights follow _draw_activity / _draw_rhc.
        act_y1 = my1
        act_y0 = act_y1 - (3 * pad + 4 * th10)
        rhc_y1 = act_y0 - PANE_GAP
        rhc_y0 = rhc_y1 - (5 * pad + 6 * th10 + RHC_BTN)
        self._draw_rhc(f6_x0, rhc_y0, f6_x1, rhc_y1)
        self._draw_activity(f6_x0, act_y0, f6_x1, act_y1)
        # The IDP column, right of C3/F6: C2 at the top, the O6 IDP LOAD
        # inset under it.
        idp_x0 = c3_x1 + PANE_GAP
        idp_x1 = idp_x0 + C2_W
        c2_y1 = self._draw_c2(idp_x0, my0, idp_x1)
        load_y1 = self._draw_idp_load(idp_x0, c2_y1 + PANE_GAP, idp_x1)
        self._draw_r11(idp_x0, load_y1 + PANE_GAP, idp_x1)

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
        self._text(self.mid, L["power_on"], "ON", size=SETTING_SIZE)

        guard_w, guard_h = 58, 124
        y1 = L["power_sw"]
        for i, cx in enumerate(self.col):
            x1, x2 = cx - guard_w / 2, cx + guard_w / 2
            y2 = y1 + guard_h
            pos = 0 if self.power[i] == "ON" else 1
            self._guarded_toggle(x1, y1, x2, y2, pos, npos=2)
            self._hit("power", i, x1, y1, x2, y2)

        self._text(self.mid, L["power_off"], "OFF", size=SETTING_SIZE)

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
        self._text(self.mid, L["out_backup"], "BACKUP", size=SETTING_SIZE)
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

        self._text(self.mid, L["out_term"], "TERMINATE", size=SETTING_SIZE)

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
        self._text(self.mid, L["mode_run"], "RUN", size=SETTING_SIZE)

        guard_w, guard_h = 58, 136
        y1 = L["mode_sw"]
        cy = y1 + guard_h / 2.0
        self._vtext(self.side_l_out, cy, "STBY")
        self._vtext(self.side_r_out, cy, "STBY")
        for i, cx in enumerate(self.col):
            x1, x2 = cx - guard_w / 2, cx + guard_w / 2
            y2 = y1 + guard_h
            pos = MODE_POS.index(self.mode[i])
            self._guarded_toggle(x1, y1, x2, y2, pos, npos=3)
            self._hit("mode", i, x1, y1, x2, y2)

        self._text(self.mid, L["mode_halt"], "HALT", size=SETTING_SIZE)

    def _draw_ipl_source(self, mx1, ex1, ey0, ey1):
        cx = (mx1 + ex1) / 2.0
        pad = 10
        th9 = self._th(9)
        ths = self._th(SETTING_SIZE)
        gw, gh = 56, 140
        # Whole cluster centred in the tab: IPL / SOURCE, then MMU 1,
        # the switch, MMU 2, with OFF on the right of the switch.
        block = (th9 + pad + th9 + pad + ths + pad + gh + pad + ths)
        top = ey0 + max(pad, (ey1 - ey0 - block) / 2.0)
        y = top + th9
        self._text(cx, y, "IPL", size=9)
        y += th9 + pad + th9
        self._text(cx, y, "SOURCE", size=9)
        y += th9 + pad + ths
        self._text(cx, y, "MMU 1", size=SETTING_SIZE)
        y1 = y + ths + pad
        x1, x2 = cx - gw / 2, cx + gw / 2
        y2 = y1 + gh
        pos = IPL_SOURCE_POS.index(self.ipl_source)
        self._guarded_toggle(x1, y1, x2, y2, pos, npos=3)
        self._hit("ipl_source", None, x1, y1, x2, y2)
        self._text(cx, y2 + pad + ths, "MMU 2", size=SETTING_SIZE)
        self._vtext(x2 + 14, (y1 + y2) / 2.0, "OFF")

    def _draw_c3(self, x0, y0, x1, y1):
        """BFC CRT DISPLAY and SELECT, the highlighted inset on panel C3."""
        self._rect_panel(x0, y0, x1, y1)
        pad = 10
        th10 = self._th(10)
        ths = self._th(SETTING_SIZE)
        gw, gh = 58, 136
        cx = (x0 + x1) / 2.0
        y = y0 + pad + th10
        self._text(cx, y, "BFC CRT", size=10)

        disp_cx = x0 + 28 + gw / 2
        sel_cx = disp_cx + gw + 50
        y = y + th10 + pad + ths
        self._text(disp_cx, y, "DISPLAY", size=SETTING_SIZE)
        self._text(sel_cx, y, "SELECT", size=SETTING_SIZE)
        y = y + ths + pad + ths
        self._text(disp_cx, y, "ON", size=SETTING_SIZE)
        self._text(sel_cx, y, "1+2", size=SETTING_SIZE)
        sw_top = y + ths + pad
        box_x0 = disp_cx - gw / 2 - 8
        box_x1 = sel_cx + gw / 2 + 8
        self._rect(box_x0, sw_top - 6, box_x1, sw_top + gh + 6,
                   fill="", outline=C_GUARD_LO, width=max(1, int(self.s)))
        mid_x = (disp_cx + sel_cx) / 2.0
        self._line(mid_x, sw_top - 6, mid_x, sw_top + gh + 6,
                   fill=C_GUARD_LO, width=max(1, int(self.s)))

        dpos = BFC_DISPLAY_POS.index(self.bfc_display)
        spos = BFC_SELECT_POS.index(self.bfc_select)
        dx1, dx2 = disp_cx - gw / 2, disp_cx + gw / 2
        sx1, sx2 = sel_cx - gw / 2, sel_cx + gw / 2
        self._guarded_toggle(dx1, sw_top, dx2, sw_top + gh, dpos, npos=2)
        self._guarded_toggle(sx1, sw_top, sx2, sw_top + gh, spos, npos=3)
        self._hit("bfc_display", None, dx1, sw_top, dx2, sw_top + gh)
        self._hit("bfc_select", None, sx1, sw_top, sx2, sw_top + gh)

        self._vtext(sx2 + 14 + SETTING_SIZE * 2 / 3.0,
                    sw_top + gh / 2.0, "2+3")
        y_bot = sw_top + gh + pad + ths
        self._text(disp_cx, y_bot, "OFF", size=SETTING_SIZE)
        self._text(sel_cx, y_bot, "3+1", size=SETTING_SIZE)

    def _draw_f6(self, x0, y0, x1, y1):
        """BFC DISENGAGE, the highlighted inset on panel F6."""
        self._rect_panel(x0, y0, x1, y1)
        pad = 10
        th10 = self._th(10)
        cx = (x0 + x1) / 2.0
        y = y0 + pad + th10
        self._text(cx, y, "BFC", size=10)
        y += th10 + pad + th10
        self._text(cx, y, "DISENGAGE", size=10)
        y += th10 + pad
        gw, gh = 124, 58
        sx1, sy1 = cx - gw / 2, y
        sx2, sy2 = cx + gw / 2, y + gh
        pos = BFC_DISENGAGE_POS.index(self.bfc_disengage)
        self._guarded_toggle_h(sx1, sy1, sx2, sy2, pos, npos=2)
        self._hit("bfc_disengage", None, sx1, sy1, sx2, sy2)

    def _draw_rhc(self, x0, y0, x1, y1):
        """BFS ENGAGE pushbuttons from the tops of the two RHCs."""
        self._rect_panel(x0, y0, x1, y1)
        pad = 10
        th10 = self._th(10)
        cx = (x0 + x1) / 2.0
        # Two lines, like BFC / DISENGAGE: one is wider than the pane.
        y = y0 + pad + th10
        self._text(cx, y, "RHC", size=10)
        y += th10 + pad + th10
        self._text(cx, y, "BFC ENGAGE", size=10)
        y += th10 + pad + th10
        quarter = (x1 - x0) / 4.0
        top = y + th10 + pad
        for i, (name, down) in enumerate(zip(RHCS, self.rhc)):
            bx = cx + (2 * i - 1) * quarter
            self._text(bx, y, name, size=10)
            bx1, bx2 = bx - RHC_BTN / 2.0, bx + RHC_BTN / 2.0
            # IPL's grey, not the vehicle's red: the ACTIVITY lamps are the
            # only colour on the panel, so they are what the eye goes to.
            self._pushbutton(bx1, top, bx2, top + RHC_BTN, "", down=down)
            self._hit("rhc", i, bx1, top, bx2, top + RHC_BTN)

    def _draw_activity(self, x0, y0, x1, y1):
        """MM1 / MM2 ACTIVITY lamps, each captioned on its left."""
        self._rect_panel(x0, y0, x1, y1)
        pad = 10
        th10 = self._th(10)
        cx = (x0 + x1) / 2.0
        y = y0 + pad + th10
        self._text(cx, y, "ACTIVITY", size=10)
        # One caption line below the title, as close as the other titles.
        row_y = y + th10 + pad + th10
        quarter = (x1 - x0) / 4.0
        for i, (name, state) in enumerate(zip(MMUS, self.activity)):
            self._lamp(cx + (2 * i - 1) * quarter, row_y, name, state)

    def _draw_c2(self, x0, y0, x1):
        """Panel C2: POWER and MAJ FUNC for IDP/CRT 1, 3, 2, and the two
        IDP/CRT SEL switches.  Returns the inset's bottom edge."""
        pad = 10
        th10 = self._th(10)
        ths = self._th(SETTING_SIZE)
        pw, ph = 58, 124        # POWER: O6 POWER's guard
        mw, mh = 58, 136        # MAJ FUNC: O6 OUTPUT's 3-position guard
        sw, sh = 124, 58        # SEL: F6 DISENGAGE's horizontal guard
        # The vertical rhythm first, so the body can be drawn behind it.
        y_idp = y0 + 2 * pad + th10
        y_crt = y_idp + th10 + pad + th10
        y_names = y_crt + th10 + pad + ths
        y_up = y_names + ths + pad + ths
        sw_top = y_up + ths + pad
        y_down = sw_top + mh + pad + ths
        box_y0 = y_idp - th10 - pad / 2.0
        box_y1 = y_down + ths + pad / 2.0
        y_sel = box_y1 + 2 * pad + th10
        y_selcrt = y_sel + th10 + pad + ths
        sel_top = y_selcrt + ths + pad
        y1 = sel_top + sh + 2 * pad
        self._rect_panel(x0, y0, x1, y1)

        width = x1 - x0
        centres = [x0 + width * (2 * k + 1) / 6.0 for k in range(3)]
        rows = (y_idp, y_crt, y_names, y_up, sw_top, y_down, box_y0, box_y1)
        for scx, n in zip(centres, C2_IDPS):
            self._idp_set(scx, n, rows)

        for side, title, scx, positions in (
                ("left", "LEFT IDP/CRT SEL", x0 + width / 4.0, LEFT_SEL_POS),
                ("right", "RIGHT IDP/CRT SEL", x0 + width * 3 / 4.0, RIGHT_SEL_POS)):
            self._text(scx, y_sel, title, size=10)
            self._text(scx, y_selcrt, "CRT", size=SETTING_SIZE)
            sx1, sx2 = scx - sw / 2, scx + sw / 2
            pos = positions.index(self.kybd_sel[side])
            self._guarded_toggle_h(sx1, sel_top, sx2, sel_top + sh, pos, npos=2)
            self._hit("kybd_sel", side, sx1, sel_top, sx2, sel_top + sh)
            cy = sel_top + sh / 2.0
            self._text(sx1 - 12, cy, positions[0], size=10)
            self._text(sx2 + 12, cy, positions[1], size=10)
        return y1

    def _idp_rows(self, y0):
        """The vertical rhythm of one IDP/CRT set, from the inset's top."""
        pad = 10
        th10 = self._th(10)
        ths = self._th(SETTING_SIZE)
        mh = 136
        y_idp = y0 + 2 * pad + th10
        y_crt = y_idp + th10 + pad + th10
        y_names = y_crt + th10 + pad + ths
        y_up = y_names + ths + pad + ths
        sw_top = y_up + ths + pad
        y_down = sw_top + mh + pad + ths
        box_y0 = y_idp - th10 - pad / 2.0
        box_y1 = y_down + ths + pad / 2.0
        return (y_idp, y_crt, y_names, y_up, sw_top, y_down, box_y0, box_y1)

    def _idp_set(self, scx, n, rows):
        """One IDP/CRT set, POWER and MAJ FUNC, centred on scx."""
        y_idp, y_crt, y_names, y_up, sw_top, y_down, box_y0, box_y1 = rows
        pw, ph = 58, 124        # POWER: O6 POWER's guard
        mw, mh = 58, 136        # MAJ FUNC: O6 OUTPUT's 3-position guard
        ow = max(1, int(self.s))
        self._rect(scx - 115, box_y0, scx + 115, box_y1,
                   fill="", outline=C_GUARD_LO, width=ow)
        self._text(scx, y_idp, "IDP/", size=10)
        self._text(scx, y_crt, "CRT %d" % n, size=10)
        pcx, mcx = scx - 55, scx + 55
        self._text(pcx, y_names, "POWER", size=SETTING_SIZE)
        self._text(mcx, y_names, "MAJ FUNC", size=SETTING_SIZE)
        self._text(pcx, y_up, "ON", size=SETTING_SIZE)
        self._text(mcx, y_up, "GNC", size=SETTING_SIZE)
        ptop = sw_top + (mh - ph) / 2.0
        pos = IDP_POWER_POS.index(self.idp_power[n - 1])
        self._guarded_toggle(pcx - pw / 2, ptop, pcx + pw / 2, ptop + ph,
                             pos, npos=2)
        self._hit("idp_power", n, pcx - pw / 2, ptop, pcx + pw / 2, ptop + ph)
        mf = self.idp_mf[n - 1]
        mx1, mx2 = mcx - mw / 2, mcx + mw / 2
        if mf == 3:
            # ILLEGAL is not a place the paddle can be: end-on, ringed
            # in red, as MEDS2's pane shows it.
            self._guarded_toggle(mx1, sw_top, mx2, sw_top + mh, 1, npos=3)
            r = mw * 0.60
            cy = sw_top + mh / 2.0
            self._oval(mcx - r, cy - r, mcx + r, cy + r, fill="",
                       outline=MF_RING, width=max(2, int(3 * self.s)))
        else:
            self._guarded_toggle(mx1, sw_top, mx2, sw_top + mh,
                                 MAJ_FUNC_POS.index(MF_NAMES[mf]), npos=3)
        self._hit("idp_mf", n, mx1, sw_top, mx2, sw_top + mh)
        self._vtext(mx2 + 14 + SETTING_SIZE * 2 / 3.0,
                    sw_top + mh / 2.0, "SM")
        self._text(pcx, y_down, "OFF", size=SETTING_SIZE)
        self._text(mcx, y_down, "PL", size=SETTING_SIZE)

    def _draw_r11(self, x0, y0, x1):
        """IDP/CRT 4's POWER and MAJ FUNC, which in the orbiter sit beside the
        aft keyboard on panel R11 (Crew Software Interface figure 2-3).  It
        has no IDP/CRT SEL: the aft keyboard reaches only IDP 4.  Returns the
        inset's bottom edge."""
        # C2's margins: the set's box 5 in from the inset's left side, as C2's
        # sets are from theirs, and as far from the bottom as from the top.
        # The right side gets 4 more, because _rect_panel's dark right-hand
        # bevel lies over the panel face while the light left one reads as
        # panel: equal numbers looked lopsided.
        pad = 10
        rows = self._idp_rows(y0)
        y1 = rows[7] + (rows[6] - y0)
        left, right = 5, 5 + 4
        width = left + 230 + right
        self._rect_panel(x0, y0, x0 + width, y1)
        self._idp_set(x0 + left + 115, 4, rows)
        return y1

    def _draw_idp_load(self, x0, y0, x1):
        """Panel O6's INTEGRATED DISPLAY PROCESSOR inset: LOAD switches 1-4,
        momentary, thrown down to load.  Returns the inset's bottom edge."""
        pad = 10
        th10 = self._th(10)
        th12 = self._th(12)
        ths = self._th(SETTING_SIZE)
        gw, gh = 58, 124
        y_title = y0 + pad + th10
        y_nums = y_title + th10 + pad + th12
        y_load = y_nums + th12 + pad + ths
        sw_top = y_load + ths + pad
        y1 = sw_top + gh + 2 * pad
        self._rect_panel(x0, y0, x1, y1)
        cx = (x0 + x1) / 2.0
        self._text(cx, y_title, "INTEGRATED DISPLAY PROCESSOR", size=10)
        self._text(cx, y_load, "LOAD", size=SETTING_SIZE)
        tw = self._tkfont(SETTING_SIZE).measure("LOAD") / max(self.s, 0.01)
        tx = cx + tw / 2.0 + 5
        t = ths * 0.45
        self._poly([(tx, y_load - t), (tx + 2 * t, y_load - t),
                    (tx + t, y_load + t)], fill=C_INK, outline="")
        width = x1 - x0
        for k in range(N_IDP_LOAD):
            gx = x0 + width * (2 * k + 1) / (2.0 * N_IDP_LOAD)
            self._text(gx, y_nums, str(k + 1), size=12)
            pos = 1 if self.idp_load[k] else 0
            self._guarded_toggle(gx - gw / 2, sw_top, gx + gw / 2, sw_top + gh,
                                 pos, npos=2)
            self._hit("idp_load", k + 1, gx - gw / 2, sw_top, gx + gw / 2,
                      sw_top + gh)
        return y1

    def _lamp(self, gx, y, caption, state, size=10):
        """Caption then disk, the pair centred on gx.

        The disk's diameter is the caption's cap height, and its centre
        is on the caps' centre rather than on the em box's.
        """
        f = self._tkfont(size)
        ascent = float(f.metrics("ascent"))
        descent = float(f.metrics("descent"))
        em = f.measure("0123456789") / (10 * HELV_DIGIT_EM)
        cap = HELV_CAP_EM * em
        s = max(self.s, 0.01)
        d = cap / s
        gap = 0.5 * d
        tw = f.measure(caption) / s
        tx = gx - (tw + gap + d) / 2.0
        self._text(tx, y, caption, size=size, anchor="w")
        # anchor w centres the linespace; the baseline is (a - d)/2 below.
        cy = y + ((ascent - descent) / 2.0 - cap / 2.0) / s
        lx = tx + tw + gap
        self._oval(lx, cy - d / 2.0, lx + d, cy + d / 2.0,
                   fill=C_LAMP[state], outline=C_INK,
                   width=max(1, int(self.s)))

    # ---- control bodies -------------------------------------------------

    def _guarded_toggle(self, x1, y1, x2, y2, pos, npos):
        """Vertical paddle switch on a circular well."""
        self._draw_paddle(x1, y1, x2, y2, pos, npos)

    def _guarded_toggle_h(self, x1, y1, x2, y2, pos, npos):
        """Horizontal paddle switch on a circular well."""
        self._draw_paddle_h(x1, y1, x2, y2, pos, npos)

    def _draw_paddle(self, x1, y1, x2, y2, pos, npos):
        """Bat-handle paddle, throwing up/down in the well."""
        self._bat_handle((x1 + x2) / 2.0, (y1 + y2) / 2.0,
                         x2 - x1, y2 - y1, pos, npos, axis="y")

    def _draw_paddle_h(self, x1, y1, x2, y2, pos, npos):
        """Bat-handle paddle, throwing left/right in the well."""
        self._bat_handle((x1 + x2) / 2.0, (y1 + y2) / 2.0,
                         x2 - x1, y2 - y1, pos, npos, axis="x")

    def _switch_disk(self, cx, cy, r):
        """Circular well behind the paddle, centred on the throw's mid position."""
        ow = max(1, int(self.s))
        self._oval(cx - r, cy - r, cx + r, cy + r,
                   fill=C_WELL, outline="#4a4840", width=ow)

    def _bushing(self, cx, cy, r):
        """Circular mounting nut the handle pivots in."""
        ow = max(1, int(self.s))
        self._oval(cx - r * 1.25, cy - r * 1.25, cx + r * 1.25, cy + r * 1.25,
                   fill="#6e6b60", outline="#3a3830", width=ow)
        self._oval(cx - r, cy - r, cx + r, cy + r,
                   fill="#b0ada0", outline="#5a584c", width=ow)
        self._oval(cx - r * 0.55, cy - r * 0.55, cx + r * 0.55, cy + r * 0.55,
                   fill="#3a3830", outline="#1a1a18", width=1)

    def _bat_handle(self, cx, cy, well_w, well_h, pos, npos, axis="y"):
        """Front-view bat-handle toggle.

        Thrown positions show the handle in the plane of the panel.
        The centre of a 3-position switch points at the camera, so the
        paddle is seen end-on.
        """
        span = well_h if axis == "y" else well_w
        thick = well_w if axis == "y" else well_h
        # Thrown-paddle cap width is 2 * 0.30 * thick; disk diameter is
        # twice that, then 10% smaller.
        paddle_w = thick * 0.60
        self._switch_disk(cx, cy, paddle_w * 0.90)
        br = thick * 0.20
        self._bushing(cx, cy, br)
        t = pos / float(npos - 1) if npos > 1 else 0.0
        if npos == 3 and pos == 1:
            self._bat_face(cx, cy, thick)
            return
        sign = -1.0 if t < 0.5 else 1.0
        self._bat_thrown(cx, cy, thick, span, sign, axis, br)

    def _bat_face(self, cx, cy, thick):
        """End-on paddle: the handle is pointing at the viewer."""
        rx, ry = thick * 0.40, thick * 0.36
        ow = max(1, int(self.s))
        # Drop shadow
        self._oval(cx - rx + 1.5, cy - ry + 2, cx + rx + 1.5, cy + ry + 2,
                   fill="#2a2a22", outline="")
        self._oval(cx - rx, cy - ry, cx + rx, cy + ry,
                   fill=C_PADDLE, outline=C_PADDLE_LO, width=ow)
        # Specular blob, upper left
        self._oval(cx - rx * 0.55, cy - ry * 0.65,
                   cx + rx * 0.05, cy - ry * 0.05,
                   fill="#ffffff", outline="")
        # Rim groove
        irx, iry = rx * 0.55, ry * 0.55
        self._oval(cx - irx, cy - iry, cx + irx, cy + iry,
                   fill="", outline=C_PADDLE_GROOVE, width=ow)

    def _bat_thrown(self, cx, cy, thick, span, sign, axis, br):
        """Paddle thrown along axis: sign -1 is up/left, +1 is down/right."""
        length = span * 0.40
        base_h = thick * 0.13
        tip_h = thick * 0.30
        along = tip_h * 0.70          # oval flattened along the shaft
        ow = max(1, int(self.s))
        # Neck starts just past the bushing so the handle reads as pivoting.
        neck = br * 0.35
        if axis == "y":
            y0 = cy + sign * neck
            y1 = cy + sign * length
            y_join = y1 - sign * along * 0.95
            pts = [
                (cx - base_h, y0),
                (cx + base_h, y0),
                (cx + tip_h, y_join),
                (cx - tip_h, y_join),
            ]
            shadow = [(x + 1.2, y + 1.8 * sign) for x, y in pts]
            self._poly(shadow, fill="#2a2a22", outline="", width=0)
            self._poly(pts, fill=C_PADDLE, outline=C_PADDLE_LO, width=ow)
            self._oval(cx - tip_h, y1 - along, cx + tip_h, y1 + along,
                       fill=C_PADDLE, outline=C_PADDLE_LO, width=ow)
            # Highlight along the left edge and on the cap
            self._line(cx - base_h * 0.45, y0,
                       cx - tip_h * 0.55, y_join,
                       fill="#ffffff", width=max(1, int(1.5 * self.s)))
            self._oval(cx - tip_h * 0.55, y1 - along * 0.70,
                       cx + tip_h * 0.05, y1 - along * 0.05,
                       fill="#ffffff", outline="")
        else:
            x0 = cx + sign * neck
            x1 = cx + sign * length
            x_join = x1 - sign * along * 0.95
            pts = [
                (x0, cy - base_h),
                (x0, cy + base_h),
                (x_join, cy + tip_h),
                (x_join, cy - tip_h),
            ]
            shadow = [(x + 1.8 * sign, y + 1.2) for x, y in pts]
            self._poly(shadow, fill="#2a2a22", outline="", width=0)
            self._poly(pts, fill=C_PADDLE, outline=C_PADDLE_LO, width=ow)
            self._oval(x1 - along, cy - tip_h, x1 + along, cy + tip_h,
                       fill=C_PADDLE, outline=C_PADDLE_LO, width=ow)
            self._line(x0, cy - base_h * 0.45,
                       x_join, cy - tip_h * 0.55,
                       fill="#ffffff", width=max(1, int(1.5 * self.s)))
            self._oval(x1 - along * 0.70, cy - tip_h * 0.55,
                       x1 - along * 0.05, cy + tip_h * 0.05,
                       fill="#ffffff", outline="")

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
            # Anchor=c centres the em box, which puts the capitals high; as in
            # _pushbutton, move down by half the descent to centre the ink.
            f = self._tkfont(TB_WORD_SIZE)
            y_fix = (f.metrics("descent") / 2.0) / max(self.s, 0.01)
            self._text((x1 + x2) / 2.0, (y1 + y2) / 2.0 + y_fix, word,
                       size=TB_WORD_SIZE)

    def _pushbutton(self, x1, y1, x2, y2, label, down=False):
        fill = C_BTN_DOWN if down else C_BTN
        dx = 2 if down else 0
        # Bezel
        self._rect(x1, y1, x2, y2, fill=C_GUARD, outline=C_GUARD_LO,
                   width=max(2, int(1.5 * self.s)))
        m = 6
        iy1, iy2 = y1 + m + dx, y2 - m + dx
        self._rect(x1 + m + dx, iy1, x2 - m + dx, iy2,
                   fill=fill, outline=C_PADDLE_LO, width=1)
        if not label:
            return
        # Anchor=c uses the full em box, so digits sit high.  Shift down by
        # half the descent to centre the ink in the inner face.
        f = self._tkfont(14)
        y_fix = (f.metrics("descent") / 2.0) / max(self.s, 0.01)
        self._text((x1 + x2) / 2.0 + dx, (iy1 + iy2) / 2.0 + y_fix,
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

    # WAIT USER.  A crew script's 'wait user' holds until someone clicks in
    # this window -- the time to arrange windows and start a recording before
    # a demonstration.  The cursor says so, and the click that carries on is
    # taken here, so it moves no control.
    WAIT_CURSOR = "target"

    def wait_for_click(self, done):
        self._user_wait = done
        self._cursor_hits = None
        self.cv.configure(cursor=self.WAIT_CURSOR)
        # NSTS_PANEL_AUTOCLICK=<seconds>: A TEST OF 'wait user'.  The click
        # arrives through the canvas's own binding, as a real one would.
        auto = os.environ.get("NSTS_PANEL_AUTOCLICK", "")
        try:
            ms = int(float(auto) * 1000)
        except ValueError:
            ms = None
        if ms is not None:
            log("NSTS_PANEL_AUTOCLICK: clicking in %.1f s" % (ms / 1000.0))
            self.root.after(ms, lambda: self.cv.event_generate(
                "<ButtonPress-1>", x=5, y=5, when="tail"))

    def _on_leave(self, _event):
        # A 'wait user' keeps its cursor: the window usually appears with the
        # pointer elsewhere, and clearing it on the way out left the arrow.
        if self._user_wait is None:
            self.cv.configure(cursor="")

    def _on_motion(self, event):
        if self._user_wait is not None:
            if str(self.cv.cget("cursor")) != self.WAIT_CURSOR:
                self.cv.configure(cursor=self.WAIT_CURSOR)
            return
        hit = self._find(event.x, event.y)
        want = bool(hit)
        if want != self._cursor_hits:
            self._cursor_hits = want
            self.cv.configure(cursor="hand2" if want else "")

    def _on_press(self, event):
        if self._user_wait is not None:
            done, self._user_wait = self._user_wait, None
            self._cursor_hits = False
            self.cv.configure(cursor="")
            done()
            return
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
            self._held = (kind, index)
        elif kind == "rhc":
            self._set_rhc(index, True)
            self._held = (kind, index)
        elif kind == "bfc_display":
            z = self._zone(event.y, y1, y2, 2)
            self._set_bfc_display(BFC_DISPLAY_POS[z])
        elif kind == "bfc_select":
            z = self._zone(event.y, y1, y2, 3)
            self._set_bfc_select(BFC_SELECT_POS[z])
        elif kind == "bfc_disengage":
            z = self._zone(event.x, x1, x2, 2)
            self._set_bfc_disengage(BFC_DISENGAGE_POS[z])
        elif kind == "idp_power":
            z = self._zone(event.y, y1, y2, 2)
            self._set_idp_power(index, IDP_POWER_POS[z])
        elif kind == "idp_mf":
            z = self._zone(event.y, y1, y2, 3)
            self._set_idp_mf(index, MF_NAMES.index(MAJ_FUNC_POS[z]))
        elif kind == "kybd_sel":
            z = self._zone(event.x, x1, x2, 2)
            positions = LEFT_SEL_POS if index == "left" else RIGHT_SEL_POS
            self._set_kybd_sel(index, positions[z])
        elif kind == "idp_load":
            self._set_idp_load(index, True)
            self._held = (kind, index)


    def _on_release(self, event):
        if self._held is None:
            return
        kind, index = self._held
        self._held = None
        if kind == "ipl":
            self._set_ipl(index, False)
        elif kind == "rhc":
            self._set_rhc(index, False)
        elif kind == "idp_load":
            self._set_idp_load(index, False)

    def _set_power(self, i, value):
        old = self.power[i]
        self.power[i] = value
        self._announce("%s POWER" % GPCS[i], old, value)
        self._changed()

    def _set_output(self, i, value):
        old = self.output[i]
        self.output[i] = value
        self._announce("%s OUTPUT" % GPCS[i], old, value)
        self._changed()

    def _set_mode(self, i, value):
        old = self.mode[i]
        self.mode[i] = value
        self._announce("%s MODE" % GPCS[i], old, value)
        self._changed()

    def _set_ipl(self, i, down):
        old = "ON" if self.ipl[i] else "OFF"
        new = "ON" if down else "OFF"
        self.ipl[i] = down
        if down and self.mode[i] != "HALT":
            new += " (ignored: not in HALT)"
        self._announce("%s IPL" % GPCS[i], old, new)
        self._changed()

    def _set_ipl_source(self, value):
        old = self.ipl_source
        self.ipl_source = value
        self._announce("IPL SOURCE", old, value)
        self._changed()

    def _set_bfc_display(self, value):
        old = self.bfc_display
        self.bfc_display = value
        self._announce("BFC CRT DISPLAY", old, value)
        self._changed()

    def _set_bfc_select(self, value):
        old = self.bfc_select
        self.bfc_select = value
        self._announce("BFC CRT SELECT", old, value)
        self._changed()

    def _set_bfc_disengage(self, value):
        old = self.bfc_disengage
        self.bfc_disengage = value
        self._announce("BFC DISENGAGE", old, value)
        self._changed()

    def _set_rhc(self, i, down):
        old = "ON" if self.rhc[i] else "OFF"
        self.rhc[i] = down
        self._announce("%s RHC BFC ENGAGE" % RHCS[i], old,
                       "ON" if down else "OFF")
        self._changed()

    # ---- the IDP controls -------------------------------------------------

    def _set_idp_power(self, n, value, heard=False):
        old = self.idp_power[n - 1]
        if value == old:
            return
        self.idp_power[n - 1] = value
        self._announce("IDP/CRT %d POWER%s" % (n, " (heard)" if heard else ""),
                       old, value)
        self._idp_publish()
        self.redraw()

    def _set_idp_mf(self, n, mf, heard=False):
        old = self.idp_mf[n - 1]
        mf &= 3
        if mf == old:
            return
        self.idp_mf[n - 1] = mf
        self._announce("IDP/CRT %d MAJ FUNC%s" % (n, " (heard)" if heard else ""),
                       MF_NAMES[old], MF_NAMES[mf])
        self._idp_publish()
        self.redraw()

    def _set_kybd_sel(self, side, value, heard=False):
        old = self.kybd_sel[side]
        if value == old:
            return
        self.kybd_sel[side] = value
        self._announce("%s IDP/CRT SEL%s" % (side.upper(), " (heard)" if heard else ""),
                       old, value)
        self._idp_publish()
        self.redraw()

    def _set_idp_load(self, n, down):
        old = self.idp_load[n - 1]
        self.idp_load[n - 1] = down
        self._announce("IDP %d LOAD" % n, "ON" if old else "OFF",
                       "ON" if down else "OFF")
        if down and not old:
            self._idp_send(n, TAG_IDP_LOAD)
        self.redraw()

    def kybd_mask(self, n):
        """KYBD_SEL for IDP n: bit 0 the left keyboard, bit 1 the right."""
        m = 0
        if self.kybd_sel["left"] == str(n):
            m |= 1
        if self.kybd_sel["right"] == str(n):
            m |= 2
        return m

    def _idp_send(self, n, *words):
        payload = struct.pack(">%dH" % len(words), *words)
        # Noted BEFORE sending: the echo can arrive before sendto returns.
        with self._rx_lock:
            self._idp_sent.append((time.monotonic(), n, payload))
            del self._idp_sent[:-64]
        try:
            self.idp_sock.sendto(payload, (D.GROUP, idp_port(n)))
            self._idp_send_failed = False
        except OSError as e:
            if not self._idp_send_failed:
                log("cannot send on IDP%d's bus: %s" % (n, e))
            self._idp_send_failed = True

    def _idp_publish(self):
        for n in range(1, N_IDP_SW + 1):
            self._idp_send(n, TAG_IDP_POWER,
                           1 if self.idp_power[n - 1] == "ON" else 0)
            self._idp_send(n, TAG_SET_MAJOR_FUNC, self.idp_mf[n - 1])
            if n <= N_IDP_C2:           # IDP 4 has no IDP/CRT SEL
                self._idp_send(n, TAG_KYBD_SEL, self.kybd_mask(n))

    def _idp_tick(self):
        """Every IDP_REPUBLISH_MS: take in what was heard, then re-assert."""
        self._idp_adopt()
        self._idp_publish()
        self.root.after(IDP_REPUBLISH_MS, self._idp_tick)

    def _listen_idp(self):
        """Thread: note every IDP_POWER, SET_MAJOR_FUNC and KYBD_SEL anybody
        else sends to IDPs 1-4."""
        socks = self._idp_socks
        if not socks:
            return
        while True:
            try:
                ready, _, _ = select.select(list(socks), [], [])
            except OSError:
                return
            for sock in ready:
                try:
                    data, _ = sock.recvfrom(65536)
                except OSError:
                    continue
                if len(data) < 4:
                    continue
                tag, value = struct.unpack(">HH", data[:4])
                if tag not in (TAG_IDP_POWER, TAG_SET_MAJOR_FUNC, TAG_KYBD_SEL):
                    continue            # FILL, CLOCK, POLL, HEARTBEAT, ...
                n = socks[sock]
                with self._rx_lock:
                    # An echo comes back within milliseconds; anything older
                    # was never heard, and must not mask a real command.
                    now = time.monotonic()
                    self._idp_sent[:] = [e for e in self._idp_sent
                                         if now - e[0] < ECHO_WINDOW_S]
                    echo = next((e for e in self._idp_sent
                                 if e[1] == n and e[2] == data), None)
                    if echo is not None:
                        self._idp_sent.remove(echo)
                        continue
                    self._idp_rx.append((n, tag, value))

    def _idp_adopt(self):
        """Move the switches to what was heard.  A KYBD_SEL's SET bit moves a
        SEL switch to that IDP; a clear bit alone says nothing about where
        the switch is."""
        with self._rx_lock:
            rx, self._idp_rx = self._idp_rx, []
        for n, tag, value in rx:
            if tag == TAG_IDP_POWER:
                self._set_idp_power(n, "ON" if value else "OFF", heard=True)
            elif tag == TAG_SET_MAJOR_FUNC:
                self._set_idp_mf(n, value, heard=True)
            elif tag == TAG_KYBD_SEL:
                if value & 1 and str(n) in LEFT_SEL_POS:
                    self._set_kybd_sel("left", str(n), heard=True)
                if value & 2 and str(n) in RIGHT_SEL_POS:
                    self._set_kybd_sel("right", str(n), heard=True)

    def set_crt(self, value):
        """BFC CRT DISPLAY and SELECT from the field value: 0 is DISPLAY OFF."""
        if value == 0:
            self._set_bfc_display("OFF")
            return
        for pos, v in CRT_SELECT_VALUE.items():
            if v == value:
                self._set_bfc_select(pos)
                self._set_bfc_display("ON")
                return
        raise ValueError("BFC CRT SELECT is 0-3, not %r" % value)

    def set_gpc_id(self, gpc_id):
        """Wire a different column: its switches, and its ID, are published."""
        if not 1 <= gpc_id <= N_GPC:
            raise ValueError("GPC ID is 1-%d, not %r" % (N_GPC, gpc_id))
        self._announce("wired GPC", GPCS[self.wired], GPCS[gpc_id - 1])
        self.wired = gpc_id - 1
        self._changed()

    def set_term_a(self, on):
        self._announce("I/O TERM A", "ON" if self.term_a else "OFF",
                       "ON" if on else "OFF")
        self.term_a = on
        self._changed()

    def set_activity(self, i, state):
        """Light ACTIVITY lamp i (0 = MM1): OFF, READY (green), BUSY (red).

        An indicator, not a control: _tick() calls this from what it hears
        of the mass memories' READY lines.
        """
        if state not in ACTIVITY_STATES:
            raise ValueError("ACTIVITY state must be one of %s, not %r"
                             % (", ".join(ACTIVITY_STATES), state))
        old = self.activity[i]
        self.activity[i] = state
        self._announce("%s ACTIVITY" % MMUS[i], old, state)
        self.redraw()


# ---- scripted playback ----------------------------------------------------
#
# discretePanel.py's language, so a rig that drives that panel can drive this
# one; see its "scripted playback" for why a crew sequence has to be a timed
# script rather than a static override.  The script is a CREW SCRIPT: the
# language, the parser and the player are crewscript.py's, and crewscript.HELP
# lists every command (it is the end of --help).  The panel commands move the
# controls, so the window, the log and the bus agree; `do` below carries them
# out.
SCRIPT_HELP = ("crew script: '<seconds> <command>' lines -- panel "
               "commands, 'keys [KB1|KB2|KB3] KEY ...', 'subtitle TEXT' -- and "
               "'wait gpc <n> mode-tb RUN|IPL|BP [timeout <s>]', after which times "
               "count from when it is met.  Panel commands act on the primary GPC "
               "until 'gpc <n>' moves them to another column.  Every command is "
               "listed at the end of this help.")
SCRIPT_EPILOG = "crew script commands (--script FILE):\n" + crewscript.HELP
IPL_HOLD_MS = 250
TB_WORD_SIZE = 9               # RUN / IPL on a talkback flag


def _on(word):
    return word.lower() in ("on", "1", "set", "true")


def _run_script(panel, entries, quit_after_ms=None):
    root = panel.root
    # WHICH COLUMN THE SCRIPT IS DRIVING.  Every column now drives its own
    # computer, so a script that brings up more than one GPC has to be able
    # to say which it means: `gpc <n>` moves the target, and it stays there
    # until moved again.  Starts at the primary column, so a script that
    # never mentions a GPC behaves exactly as it did when only one was
    # published.
    target = [panel.wired]

    def do(verb, arg):
        w = target[0]
        if verb == "gpc":
            n = int(arg)
            if not 1 <= n <= N_GPC:
                raise SystemExit("panelO6: script: GPC must be 1 to %d, got %r"
                                 % (N_GPC, arg))
            target[0] = n - 1
        elif verb == "mode":
            name = {"STANDBY": "STBY"}.get(arg.upper(), arg.upper())
            if name not in MODE_POS:
                raise SystemExit("panelO6: unknown mode %r" % arg)
            panel._set_mode(w, name)
        elif verb == "ipl":
            panel._set_ipl(w, True)
            root.after(IPL_HOLD_MS, lambda: panel._set_ipl(w, False))
        elif verb == "source":
            name = {"MM1": "MMU 1", "MM2": "MMU 2",
                    "OFF": "OFF"}.get(arg.upper())
            if name is None:
                raise SystemExit("panelO6: unknown source %r" % arg)
            panel._set_ipl_source(name)
        elif verb == "crt":
            panel.set_crt(int(arg))
        elif verb == "bfsengage":
            bfsengage(_on(arg))
        elif verb == "gpcid":
            panel.set_gpc_id(int(arg))
        elif verb == "bit":
            reg, num, val = arg.split()
            reg = D.REG_A if reg.upper() == "A" else D.REG_B
            num, on = int(num), _on(val)
            if reg == D.REG_A and num == TERM_A_BIT:
                panel.set_term_a(on)
            elif reg == D.REG_A and num == TERM_B_BIT:
                panel._set_output(w, "TERMINATE" if on else "NORMAL")
            elif reg == D.REG_B and num in BFS_ENGAGE_BITS:
                bfsengage(on)
            elif reg == D.REG_B and num in CRT_SELECT_BITS:
                place = 1 << (len(CRT_SELECT_BITS) - 1
                              - CRT_SELECT_BITS.index(num))
                v = panel.crt_value()
                panel.set_crt(v | place if on else v & ~place)
            else:
                D.publish(panel.sock, D.SET if on else D.RESET, reg,
                          D.bit_mask(num), port=D.gpc_port(w + 1))
        elif verb == "idppower":
            n, val = arg.split()
            panel._set_idp_power(c2_idp(n), "ON" if _on(val) else "OFF")
        elif verb == "majfunc":
            n, val = arg.split()
            if val.upper() not in MAJ_FUNC_POS:
                raise SystemExit("panelO6: MAJ FUNC is GNC, SM or PL, not %r" % val)
            panel._set_idp_mf(c2_idp(n), MF_NAMES.index(val.upper()))
        elif verb == "kybdsel":
            side, val = arg.split()
            side = side.lower()
            positions = {"left": LEFT_SEL_POS, "right": RIGHT_SEL_POS}.get(side)
            if positions is None or val not in positions:
                raise SystemExit("panelO6: kybdsel is 'left 1|3' or 'right 2|3', "
                                 "not %r" % arg)
            panel._set_kybd_sel(side, val)
        elif verb == "idpload":
            n = int(arg)
            if not 1 <= n <= N_IDP_LOAD:
                raise SystemExit("panelO6: IDP LOAD is 1 to %d, not %r"
                                 % (N_IDP_LOAD, arg))
            panel._set_idp_load(n, True)
            root.after(IPL_HOLD_MS, lambda: panel._set_idp_load(n, False))
        # Every other control, by its panel legend, as the crew would move it.
        elif verb == "power":
            panel._set_power(w, position("GPC POWER", arg, POWER_POS))
        elif verb == "output":
            panel._set_output(w, position("GPC OUTPUT", arg, OUTPUT_POS))
        elif verb == "display":
            panel._set_bfc_display(position("BFC CRT DISPLAY", arg, BFC_DISPLAY_POS))
        elif verb == "select":
            panel._set_bfc_select(position("BFC CRT SELECT", arg, BFC_SELECT_POS))
        elif verb == "disengage":
            panel._set_bfc_disengage(position("BFC DISENGAGE", arg, BFC_DISENGAGE_POS))
        elif verb == "rhcengage":
            i = RHCS.index(position("RHC BFC ENGAGE", arg, RHCS))
            panel._set_rhc(i, True)
            root.after(IPL_HOLD_MS, lambda: panel._set_rhc(i, False))
        else:
            raise SystemExit("panelO6: unknown command %r" % verb)

    def c2_idp(word):
        n = int(word)
        if not 1 <= n <= N_IDP_SW:
            raise SystemExit("panelO6: IDP/CRT is 1 to %d (4 is on R11), not %r"
                             % (N_IDP_SW, word))
        return n

    def position(control, arg, positions):
        value = arg.strip().upper()
        if value not in positions:
            raise SystemExit("panelO6: %s is %s, not %r"
                             % (control, " | ".join(positions), arg))
        return value

    def bfsengage(on):
        if on:
            panel._set_rhc(0, True)
            root.after(IPL_HOLD_MS, lambda: panel._set_rhc(0, False))
        else:
            panel._set_bfc_disengage("RIGHT")
            root.after(IPL_HOLD_MS,
                       lambda: panel._set_bfc_disengage("LEFT"))

    # ONE PLAYER FOR THE WHOLE CREW SCRIPT: its clock and its waits time the
    # switches above and the keystrokes and captions alike (crewscript.py).
    crewscript.Player(entries, root.after, do,
                      lambda gpc: panel.mode_tb(gpc - 1), log,
                      wait_user=panel.wait_for_click).start()
    if quit_after_ms is not None:
        root.after(quit_after_ms, root.quit)


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Space Shuttle panels O6, C3, F6 and C2: the GPC crew panel on the\n"
                    "discrete bus, and the IDP controls on the IDP buses.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=SCRIPT_EPILOG)
    ap.add_argument("--size", type=int, default=FULL_SIZE, metavar="N",
                    help="Scale: 768 is full size (default), 512 is 2/3, 384 is half, etc.")
    ap.add_argument("--geometry", metavar="SPEC", default=None,
                    help="Tk geometry, e.g. 948x1250+80+20 (overrides --size; "
                         "also NSTS_O6_GEOMETRY)")
    ap.add_argument("--gpc-id", type=int, metavar="N", default=DEFAULT_GPC_ID,
                    help="the GPC this panel treats as primary: the column "
                         "the log marks, and the discrete channel it listens "
                         "on for mass memory READY (default 1).  It no longer "
                         "selects what is PUBLISHED -- every column now drives "
                         "its own computer on that computer's channel, port "
                         "6980 + GPC ID, and each reads its own ID in discrete "
                         "B bits 0-2.  Same numbering as yaGPC2's --gpc-id, "
                         "which now picks the same channel.")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range the buses use: the "
                         "discrete bus is base+80 (default 6900).  The same "
                         "option as on yaGPC2 and MEDS2.py. "
                         "NSTS_BUS_PORT_BASE sets it too.")
    ap.add_argument("--script", metavar="FILE", help=SCRIPT_HELP)
    ap.add_argument("--show", action="store_true",
                    help="show the panel window during a --script run too (it is "
                         "hidden otherwise, unless the script has a 'wait user')")
    ap.add_argument("--wait-user", action="store_true",
                    help="hold the --script until someone clicks in the panel window, "
                         "as if its first line were 'wait user' (and show the window)")
    ap.add_argument("--quit-after", type=int, metavar="MS",
                    help="exit this many ms after startup (for scripted runs)")
    args = ap.parse_args(argv)
    if args.size <= 0:
        raise SystemExit("panelO6: --size must be a positive integer")
    if not 1 <= args.gpc_id <= N_GPC:
        raise SystemExit("panelO6: --gpc-id must be 1..%d" % N_GPC)
    # Before any socket is opened.
    if args.port_base is not None:
        D.set_port_base(args.port_base)
    # Every column publishes on its own computer's channel (see _publish);
    # this sets the module's own channel, which is the one the MM READY
    # listener subscribes to.
    D.set_gpc(args.gpc_id)

    root = tk.Tk()
    panel = PanelO6(root, size=args.size, gpc_id=args.gpc_id)
    geom = args.geometry or os.environ.get("NSTS_O6_GEOMETRY")
    if geom:
        try:
            root.geometry(geom)
        except tk.TclError as e:
            raise SystemExit("panelO6: bad --geometry %r: %s" % (geom, e))
    else:
        w, h = scaled_wh(REF_W, REF_H, args.size)
        root.geometry("%dx%d" % (w, h))
    entries, text = None, ""
    if args.wait_user and not args.script:
        raise SystemExit("panelO6: --wait-user holds a --script; there is none")
    if args.script:
        with open(args.script) as f:
            text = f.read()
        try:
            entries = crewscript.parse(text)
        except crewscript.ScriptError as e:
            raise SystemExit("panelO6: %s" % e)
        # --wait-user: the pause a demonstration needs, without putting a
        # 'wait user' into a script that also runs unattended.
        if args.wait_user:
            entries.insert(0, {"kind": "wait_user", "text": "wait user (--wait-user)",
                               "line": 0})
    # An unattended scripted run has nobody watching it, so it gets no
    # window -- unless asked for one (--show, for a demonstration), or the
    # script waits for someone to click in it.
    _dont_steal_focus(root, mapWindow=(not args.script or args.show or args.wait_user
                                       or crewscript.has_wait_user(text)))
    if entries is not None:
        _run_script(panel, entries, args.quit_after)
    elif args.quit_after is not None:
        root.after(args.quit_after, root.quit)
    # Keep a reference so the panel is not collected.
    root._panel = panel
    root.mainloop()


if __name__ == "__main__":
    main()
