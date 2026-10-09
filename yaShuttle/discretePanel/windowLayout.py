#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Save where the simulation's windows are, and put them back later.

    python3 windowLayout.py save demo.layout     # arrange them, then save
    python3 windowLayout.py restore demo.layout  # next run, same places
    python3 windowLayout.py show                 # what is on screen now
    python3 windowLayout.py show demo.layout     # what a file holds

A run started by simulatePASS.py opens a window per display, per keyboard,
the crew panel, the CAM and the caption box, and the places they land in are
rarely the ones wanted for a recording.  Arrange them once by hand, save, and
every later run can be put back the same way.

WHAT A WINDOW IS CALLED.  Not its title -- two keyboards are titled "1" and
"2" -- and not its WM_CLASS, which for Tk is "tk #4" and changes run to run.
Each window is named for the program that made it, from that process's own
command line, so the same name matches the same window in a later run:

    crt1 crt2 crt3 crt4     the MEDS2.py displays
    kybd1 kybd2 kybd3       the DPS keyboards
    panel                   panelO6.py
    cam                     cam.py
    subtitles               subtitles.py
    meds:<name>             any other MEDS2.py window, by its LRU name

Anything not recognised is saved under 'other:<title>', matched by title.

THE CAPTION BOX'S LOOK is saved too -- font, size, colours, opacity and
alignment, which subtitles.py keeps on its own window (_NSTS_SUBTITLES) and
updates as they are changed in --edit.  simulatePASS.py --layout starts the
box with exactly those options.

SIZES.  Every window is restored at the size it was saved at, not just moved.
All of them are resizable by hand, and the usual reason to restore a layout is
to undo a change made by accident -- a window dragged bigger is exactly such a
change, so putting it back where it was without putting it back at the size it
was does only half the job.  'restore --no-sizes' moves without resizing;
'--with-sizes' is now what happens anyway and is accepted so that older command
lines and scripts keep working.

WHOSE WINDOWS.  'restore' moves whatever it finds by that name, so with two
simulations running it may move the wrong one's; it says so when a name
matches more than one window.  simulatePASS.py --layout does not have this
problem: it notes what was on screen before it started and places only its
own windows.

A window manager may place a window a few pixels from where it is asked to
(the frame is its business, not ours), so each window is moved, measured, and
nudged by the difference, up to five times.  --verbose shows that happening.

WHAT IT CANNOT DO.  Marco keeps a window on ONE monitor: asked for a place
where the window would straddle the boundary, it shoves it back, and asked
for one further over it moves it to the next monitor entirely.  A layout
saved from windows that were placed by hand never asks for the impossible;
one written by hand can, and then a window ends up somewhere else and the
report says how far off it finished.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time

import procinfo

# Tk tells nobody its process id, so its windows are named by title instead.
TITLE_ROLES = [
    (re.compile(r"^Subtitles$"), "subtitles"),
    # Panel O1, which holds the CAM.  "CAM" is the title it had before, kept
    # so a layout saved then still finds it; the role stays "cam" either way.
    (re.compile(r"^(O1|CAM)$"), "cam"),
    # BOTH TITLES THE PANEL HAS WORN.  It is "Panel" now -- the task bar shows
    # a few characters and a long title made every button look alike -- but a
    # layout saved before that, or an older copy of panelO6.py, still says
    # "Panels O6, ...".
    (re.compile(r"^Panel$|^Panels O6\b"), "panel"),
    (re.compile(r"^GPC discrete panel"), "discretepanel"),
    (re.compile(r"^Manager\b"), "manager"),
    # handcontrollers.py's window, by the controllers it stands in for.
    (re.compile(r"^THC (FWD|AFT) / RHC (LH|AFT)$"),
     lambda m: "hc_%s_%s" % (m.group(1).lower(), m.group(2).lower())),
    (re.compile(r"^RHC RH$"), "hc_rh"),
    # truthball.py, the debugging attitude indicator driven by the truth.
    (re.compile(r"^Truth ADI$"), "truthball"),
    (re.compile(r"^([123])$"), lambda m: "kybd%s" % m.group(1)),
    # A DISPLAY BY ITS OWN NAME, now that its title is just "CRT1".  The
    # command line is tried first and normally answers; this is the fallback
    # for a window whose process cannot be read.
    (re.compile(r"^(CRT|CDR|PLT|MFD|AFD)(\d)$", re.I),
     lambda m: m.group(0).lower()),
]
def _hc_role(rhc):
    """handcontrollers.py's layout role, from its --rhc (the station)."""
    return {"rh": "hc_rh", "aft": "hc_aft_aft"}.get((rhc or "").lower(), "hc_fwd_lh")


ROLE_PATTERNS = [
    # (what to look for in the command line, the name to give it)
    (re.compile(r"stsKeyboard\.py.*--kybd\s+(\d)"), lambda m: "kybd%s" % m.group(1)),
    (re.compile(r"MEDS2\.py.*\b(crt\d|cdr\d|plt\d|mfd\d|afd\d)\b"), lambda m: m.group(1)),
    (re.compile(r"MEDS2\.py"), lambda m: "meds"),
    (re.compile(r"panelO6\.py"), lambda m: "panel"),
    (re.compile(r"discretePanel\.py"), lambda m: "discretepanel"),
    (re.compile(r"cam\.py"), lambda m: "cam"),
    (re.compile(r"subtitles\.py"), lambda m: "subtitles"),
    # THE MANAGER'S OWN WINDOW.  It was missing, so the one window a person
    # keeps in a particular corner -- the one with the buttons -- was the one
    # window a layout could not put back.
    (re.compile(r"manager\.py"), lambda m: "manager"),
    # The virtual hand controllers' window (handcontrollers.py with no stick).
    # Its station, from --rhc alone: hc_fwd_lh (CDR, also the default),
    # hc_aft_aft (aft), hc_rh (PLT, no THC).
    (re.compile(r"handcontrollers\.py(?=.*--rhc[ =](\w+))?"),
     lambda m: _hc_role(m.group(1))),
    # truthball.py's window (simulatePASS --truth-ball).
    (re.compile(r"truthball\.py"), lambda m: "truthball"),
]


HOSTNAME = os.uname().nodename if hasattr(os, "uname") else ""   # X11 only


# ---------------------------------------------------------------------------
# Windows.  Its own window functions, through ctypes: EnumWindows lists the
# windows, each of which knows its process, and SetWindowPos moves them.
#
# WHAT A LAYOUT'S NUMBERS MEAN THERE.  The same as everywhere else, so that
# one layout file serves every platform: x and y are where the INSIDE of the
# window is -- its client area, the part the program draws -- plus the offset
# a Linux layout carries for a decorated window (MARCO_FRAME_OFFSET, below),
# and w and h are the inside's size.  So a layout made on Linux puts each
# window's contents on the same pixels here.  The frames around them are
# Windows' own and a little thinner than Marco's, which shows as slightly
# wider gaps between windows and nothing else.
#
# PHYSICAL PIXELS, or none of that is true.  A Windows program that has not
# declared itself DPI-aware is shown a make-believe 96-dpi screen and has its
# windows stretched to fit the real one: at 150% every coordinate it sees is
# two-thirds of the truth, and its text is blurred.  Python's Tk is such a
# program until told otherwise.  So this module declares it on import, which
# every program here does before it makes a window -- "per monitor", the
# same as Qt declares for itself, so MEDS2.py is not asked for two different
# things.  After that Tk's geometry is in real pixels, as on Linux.

WIN = sys.platform == "win32"
_WIN = None


def win_dpi_aware():
    """Declare this process DPI-aware (Windows), before it has a window.
    Harmless to repeat, and a no-op anywhere else."""
    if not WIN:
        return
    import ctypes
    try:
        # Per-monitor, version 2 (Windows 10 1703): -4 is its context handle.
        ctypes.windll.user32.SetProcessDpiAwarenessContext(ctypes.c_void_p(-4))
    except (AttributeError, OSError):
        try:
            ctypes.windll.shcore.SetProcessDpiAwareness(2)      # Windows 8.1
        except (AttributeError, OSError):
            pass


win_dpi_aware()


def _win():
    """user32 and dwmapi with the argument types that matter on 64 bits,
    where a window handle passed as a plain int would be cut in half."""
    global _WIN
    if _WIN is None:
        import ctypes
        from ctypes import wintypes
        u = ctypes.WinDLL("user32", use_last_error=True)
        d = ctypes.WinDLL("dwmapi")
        proc = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
        u.EnumWindows.argtypes = [proc, wintypes.LPARAM]
        u.IsWindowVisible.argtypes = [wintypes.HWND]
        u.IsWindow.argtypes = [wintypes.HWND]
        u.IsIconic.argtypes = [wintypes.HWND]
        u.ShowWindow.argtypes = [wintypes.HWND, ctypes.c_int]
        u.GetWindowTextLengthW.argtypes = [wintypes.HWND]
        u.GetWindowTextW.argtypes = [wintypes.HWND, wintypes.LPWSTR, ctypes.c_int]
        u.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
        u.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
        u.GetClientRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
        u.ClientToScreen.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.POINT)]
        u.GetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int]
        u.GetWindowLongW.restype = wintypes.LONG
        u.SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int,
                                   ctypes.c_int, ctypes.c_int, wintypes.UINT]
        d.DwmGetWindowAttribute.argtypes = [wintypes.HWND, wintypes.DWORD,
                                            ctypes.c_void_p, wintypes.DWORD]
        u.MonitorFromPoint.argtypes = [wintypes.POINT, wintypes.DWORD]
        u.MonitorFromPoint.restype = wintypes.HMONITOR
        u.GetMonitorInfoW.argtypes = [wintypes.HMONITOR, ctypes.c_void_p]
        _WIN = (ctypes, wintypes, u, d, proc)
    return _WIN


def _win_hwnd(wid):
    return int(wid, 16)


def _win_windows():
    ctypes, wintypes, u, d, proc = _win()
    found = []

    def each(hwnd, _lparam):
        if not u.IsWindowVisible(hwnd):
            return True
        n = u.GetWindowTextLengthW(hwnd)
        if n <= 0:
            return True
        # "Cloaked": there as far as EnumWindows is concerned and not on
        # screen -- a window on another virtual desktop, or one of the shell's
        # own that is kept ready and never shown.
        cloaked = wintypes.DWORD(0)
        d.DwmGetWindowAttribute(hwnd, 14, ctypes.byref(cloaked), ctypes.sizeof(cloaked))
        if cloaked.value:
            return True
        buf = ctypes.create_unicode_buffer(n + 1)
        u.GetWindowTextW(hwnd, buf, n + 1)
        pid = wintypes.DWORD(0)
        u.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
        found.append((hwnd, int(pid.value), buf.value))
        return True

    u.EnumWindows(proc(each), 0)
    out = []
    for hwnd, pid, title in found:
        wid = "0x%08x" % hwnd
        where = _win_geometry(wid)
        if where is None:
            continue
        role, cmd = role_of(pid, title)
        entry = {"id": wid, "pid": pid, "x": where[0], "y": where[1],
                 "w": where[2], "h": where[3], "title": title, "role": role, "cmd": cmd}
        if role == "subtitles":
            entry["look"] = _mac_look(pid)      # a file there too; see subtitles.py
        out.append(entry)
    return out


def _win_inside(hwnd):
    """(left, top, width, height) of the window's client area on the screen,
    and whether the window has a title bar."""
    ctypes, wintypes, u, _d, _proc = _win()
    if not u.IsWindow(hwnd):
        return None
    rect, origin = wintypes.RECT(), wintypes.POINT(0, 0)
    if not u.GetClientRect(hwnd, ctypes.byref(rect)):
        return None
    if not u.ClientToScreen(hwnd, ctypes.byref(origin)):
        return None
    GWL_STYLE, WS_CAPTION = -16, 0x00C00000
    framed = (u.GetWindowLongW(hwnd, GWL_STYLE) & WS_CAPTION) == WS_CAPTION
    return origin.x, origin.y, rect.right - rect.left, rect.bottom - rect.top, framed


def _win_geometry(wid):
    inside = _win_inside(_win_hwnd(wid))
    if inside is None:
        return None
    x, y, w, h, framed = inside
    dx, dy = MARCO_FRAME_OFFSET if framed else (0, 0)
    return x + dx, y + dy, w, h


def _win_reachable(hwnd, wx, wy, outer):
    """How far to move a window whose outer rectangle will have its top-left
    at (wx, wy) so that its title bar can be grabbed: the visible frame's top
    no higher than the top of the work area of the monitor it lands on, and
    some of the bar's width on that monitor.  A layout made on Linux places
    the INSIDE of a window where Marco put it, and Marco's 80-pixel offset
    includes the desktop's top panel; Windows' title bar must then fit above
    an inside at the top of the screen, and went off it (Win11-native,
    2026-10-07: frames at y = -45 at 144 dpi, impossible to drag)."""
    ctypes, wintypes, u, d, _proc = _win()

    class MONITORINFO(ctypes.Structure):
        _fields_ = [("cbSize", wintypes.DWORD), ("rcMonitor", wintypes.RECT),
                    ("rcWork", wintypes.RECT), ("dwFlags", wintypes.DWORD)]
    vis = wintypes.RECT()
    # DWMWA_EXTENDED_FRAME_BOUNDS: the frame as drawn, without the invisible
    # resize borders that GetWindowRect counts
    if d.DwmGetWindowAttribute(hwnd, 9, ctypes.byref(vis), ctypes.sizeof(vis)) != 0:
        vis = outer
    top_off, left_off = vis.top - outer.top, vis.left - outer.left
    vis_w = vis.right - vis.left
    mi = MONITORINFO()
    mi.cbSize = ctypes.sizeof(MONITORINFO)
    mon = u.MonitorFromPoint(wintypes.POINT(int(wx + left_off + vis_w // 2), int(wy + top_off)), 2)
    if not mon or not u.GetMonitorInfoW(mon, ctypes.byref(mi)):
        return 0, 0
    work = mi.rcWork
    sx = sy = 0
    if wy + top_off < work.top:
        sy = work.top - (wy + top_off)
    grip = min(100, vis_w)                      # enough of the bar to take hold of
    vl = wx + left_off
    if vl + vis_w < work.left + grip:
        sx = work.left + grip - (vl + vis_w)
    elif vl > work.right - grip:
        sx = work.right - grip - vl
    return sx, sy


def _win_place(wid, x, y, w=None, h=None, verbose=False):
    """As place(): True when it is where it was asked to be, None if it has
    gone, else how far out it finished.  Windows will not let a window's
    title bar leave the screen altogether and a program may refuse a size,
    so it is measured afterwards, not assumed."""
    ctypes, wintypes, u, _d, _proc = _win()
    hwnd = _win_hwnd(wid)
    SWP_NOSIZE, SWP_NOZORDER, SWP_NOACTIVATE = 0x0001, 0x0004, 0x0010
    now = None
    for attempt in range(3):
        if u.IsIconic(hwnd):
            u.ShowWindow(hwnd, 4)               # SW_SHOWNOACTIVATE: a minimised
            time.sleep(0.2)                     # window has no place to measure
        inside = _win_inside(hwnd)
        outer = wintypes.RECT()
        if inside is None or not u.GetWindowRect(hwnd, ctypes.byref(outer)):
            return None
        cx, cy, cw, ch, framed = inside
        dx, dy = MARCO_FRAME_OFFSET if framed else (0, 0)
        # The frame's own share: how far the inside sits within the whole
        # window, and how much bigger the whole window is than the inside.
        # SetWindowPos places the whole window, invisible resize borders and
        # all, so both are taken off the inside that is wanted.
        left, top = cx - outer.left, cy - outer.top
        extra_w = (outer.right - outer.left) - cw
        extra_h = (outer.bottom - outer.top) - ch
        flags = SWP_NOZORDER | SWP_NOACTIVATE
        if w and h:
            size = (int(w) + extra_w, int(h) + extra_h)
        else:
            size, flags = (0, 0), flags | SWP_NOSIZE
        wx, wy = int(x) - dx - left, int(y) - dy - top
        sx, sy = _win_reachable(hwnd, wx, wy, outer)
        if (sx or sy) and verbose:
            print("    moved %+d,%+d to keep the title bar on the screen" % (sx, sy))
        x, y = x + sx, y + sy                   # where it can be: judged against that
        u.SetWindowPos(hwnd, None, wx + sx, wy + sy, size[0], size[1], flags)
        time.sleep(0.2)
        now = _win_geometry(wid)
        if now is None:
            return None
        if verbose:
            print("    try %d: asked %d,%d got %d,%d" % (attempt + 1, x, y, now[0], now[1]))
        if abs(now[0] - x) <= 1 and abs(now[1] - y) <= 1:
            return True
    return (x - now[0], y - now[1])


def run(cmd, timeout=10):
    """Never wait on a window that will not answer: every call is bounded."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def cmdline(pid):
    if not os.path.isdir("/proc"):
        return procinfo.cmdline(pid)            # macOS, Windows
    try:
        with open("/proc/%d/cmdline" % pid, "rb") as fh:
            return " ".join(fh.read().decode("utf-8", "replace").split("\0")).strip()
    except OSError:
        return ""


def descendants(root):
    """root and every process descended from it, from /proc.

    WHAT MAKES A WINDOW ONE SIMULATION'S RATHER THAN ANOTHER'S.  A role
    ("crt1", "panel") says what a window is, not whose: two simulations on
    one desktop have one of each, and matching by role alone moved the
    owner's windows to another workspace when a test run placed its own
    (2026-09-19).  Ancestry is what separates them, and it survives a
    restore, because the relaunched children are simulatePASS's too."""
    children = {}
    if not os.path.isdir("/proc"):
        children = procinfo.children()          # macOS
    for d in (os.listdir("/proc") if os.path.isdir("/proc") else ()):
        if not d.isdigit():
            continue
        try:
            with open("/proc/%s/stat" % d) as fh:
                st = fh.read()
            ppid = int(st[st.rindex(")") + 2:].split()[1])
        except (OSError, ValueError, IndexError):
            continue
        children.setdefault(ppid, []).append(int(d))
    out, todo = set(), [root]
    while todo:
        p = todo.pop()
        if p in out:
            continue
        out.add(p)
        todo.extend(children.get(p, []))
    return out


def claim(root, delay_ms=300):
    """Stamp this process's PID on a Tk window, so descendants() can tell
    whose it is.

    Tk does not set _NET_WM_PID, and wmctrl reports 0 for every window that
    lacks it -- the panel, the CAM, the keyboards, the manager and the
    captions all did, leaving role as the only thing to match on.  Set on
    Tk's WRAPPER -- the parent of winfo_id(), which is the window the window
    manager lists -- and after the window exists; never fatal.  NOT on
    wm_frame(): once the window manager has reparented the window, that
    names the manager's decoration frame, and a PID put there is never seen
    (measured: frame 0xbf3481, listed window 0x05e00004).

    Also where NSTS_TK_CURSOR takes effect: a pointer for the window, and for
    any Toplevel it opens, in place of the one inherited from the window
    manager's frame.  simulatePASS.py sets it on WSL only, where that
    inherited arrow is 24 px beside Tk's and Qt's own themed 48.

    And, on Windows, where NSTS_TK_SCALING takes effect: Tk's pixels per
    point, which simulatePASS.py sets so that text is the size it is on the
    Linux desktop the windows were drawn for.  Here because this is called
    straight after Tk() in every program, before any font exists to have
    been sized the old way.  Nothing else is needed on Windows: a window
    there already says whose it is."""
    if WIN:
        scaling = os.environ.get("NSTS_TK_SCALING")
        if scaling:
            try:
                root.tk.call("tk", "scaling", float(scaling))
            except Exception:
                pass
        return
    cursor = os.environ.get("NSTS_TK_CURSOR")
    if cursor:
        try:
            root.configure(cursor=cursor)
            root.option_add("*Toplevel.cursor", cursor)
        except Exception:
            pass

    def stamp():
        try:
            root.update_idletasks()
            tree = subprocess.run(["xwininfo", "-tree", "-id", str(root.winfo_id())],
                                  capture_output=True, text=True, timeout=5).stdout
            m = re.search(r"Parent window id:\s*(0x[0-9a-fA-F]+)", tree)
            if m is None:
                return
            subprocess.run(["xprop", "-id", str(int(m.group(1), 16)),
                            "-f", "_NET_WM_PID", "32c",
                            "-set", "_NET_WM_PID", str(os.getpid())],
                           check=False, stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=5)
        except Exception:
            pass
    root.after(delay_ms, stamp)


# panelO6.py's windows, one per numbered panel, titled with the number alone
# -- O6, C3, F6, A6U, R11 ... -- and so told apart by title, though they
# share one process (owner, 2026-10-02).
PANEL_TITLE = re.compile(r"^([ACFLOR]\d{1,2}[ULR]?)$")
PANEL_BASE_ROLES = {"panel_o6", "panel_c2", "panel_r11"}   # up from the start
# portview.py's windows (the views out of the Orbiter's windows), by title.
PORTVIEW_ROLES = {"CDR/PLT Forward View": "pv_front", "CDR/PLT Overhead View": "pv_up",
                  "CDR Side View": "pv_left", "PLT Side View": "pv_right",
                  # the aft flight deck's: its overhead window, the ODS
                  # centerline camera and the A3 monitor's picture of it --
                  # missing here, so a layout neither saved nor placed them
                  # (owner, 2026-10-09)
                  "Aft Station Overhead View": "pv_aft", "ODS Centerline Camera": "pv_cl",
                  "A3 MON 1": "pv_cctv",
                  "A3 MON 1: Centerline Camera": "pv_cctv"}   # its title before 2026-10-09


def role_of(pid, title):
    cmd = cmdline(pid) if pid else ""
    m = PANEL_TITLE.match(title.strip())
    if m and (not cmd or "panelO6.py" in cmd):
        return "panel_" + m.group(1).lower(), cmd
    # portview.py's four windows, one process: told apart by title.
    if title.strip() in PORTVIEW_ROLES and (not cmd or "portview.py" in cmd):
        return PORTVIEW_ROLES[title.strip()], cmd
    for pattern, name in ROLE_PATTERNS:
        m = pattern.search(cmd)
        if m:
            return name(m), cmd
    title = title.strip()
    for pattern, name in TITLE_ROLES:
        m = pattern.match(title)
        if m:
            return (name(m) if callable(name) else name), cmd
    return "other:" + title, cmd


# ---------------------------------------------------------------------------
# macOS.  There is no wmctrl or xdotool there; the Accessibility interface,
# reached through System Events with osascript, lists, measures, moves and
# resizes any application's windows -- Tk's and Qt's alike.  Positions and
# sizes are in points from the top left of the main screen, the units every
# window is placed in there, and cover the whole window, title bar included.
# A window is named by its process and its title, "mac:<pid>:<title>".
#
# THE PERMISSION.  Moving another program's windows needs Accessibility access
# for whatever runs this -- System Settings > Privacy & Security >
# Accessibility, for Terminal -- and macOS asks once for leave to script
# System Events.  Without them every call below fails, and a layout places
# nothing and says so, which is what happened before this existed.

MAC = sys.platform == "darwin"

# WHAT A LAYOUT'S NUMBERS MEAN ON macOS: the same as everywhere else, so one
# file serves every platform -- x and y where the window's INSIDE is plus
# Marco's frame offset for a titled window (MARCO_FRAME_OFFSET; none for the
# caption box, which is untitled on Linux), w and h the inside's size, all in
# the physical pixels of a scale-2 desktop.  The Accessibility interface
# works in points and in whole windows, title bar included, so the macOS
# functions below turn one into the other: MAC_UNIT pixels a point, as
# simulatePASS.py lays macOS out (tk_unit_scale), and the inside begins
# MAC_TITLE_BAR points below the window's top, with no border at the sides
# (measured on macOS 27, Tk and Qt alike).
#
# CLOSE, NOT EXACT, FROM LINUX.  A layout made on Linux puts each window's
# inside where it was there, but three things differ.  macOS pushes a window
# out from under the Dock.  The caption box has a title bar on macOS and not
# on Linux, so its bar stands above the place.  And the panels carry a
# margin at the bottom for the rounded corners that Linux has no need of.
# Windows laid out edge to edge on Linux may therefore overlap a little.
#
# OLD macOS LAYOUTS, saved before this, hold whole windows in points.  A file
# does not say which it holds, but its sizes do: at the same --size a window
# is about twice as many pixels as points.  restore_layout() compares the
# file's sizes with the windows on screen and takes an old file as it was
# meant.
MAC_UNIT = 2
MAC_TITLE_BAR = 32

_MAC_LIST = """
function run(argv) {
  // By process id: processes picked out by name all resolve to the FIRST
  // process of that name, and every Python program here is named "Python".
  var se = Application("System Events"), out = [];
  var pids = se.processes.whose({name: "Python"}).unixId();
  for (var i = 0; i < pids.length; i++) {
    try {
      var ws = se.processes.whose({unixId: pids[i]})[0].windows;
      var names = ws.name(), pos = ws.position(), sz = ws.size();
      for (var j = 0; j < names.length; j++)
        out.push({pid: pids[i], title: names[j] || "", x: pos[j][0], y: pos[j][1],
                  w: sz[j][0], h: sz[j][1]});
    } catch (e) {}
  }
  return JSON.stringify(out);
}
"""

_MAC_WINDOW = """
function run(argv) {
  var se = Application("System Events");
  // Left as specifiers: resolving them first names the process "Python",
  // which is the first Python process rather than this one.
  var p = se.processes.whose({unixId: parseInt(argv[0])})[0];
  var w = p.windows.whose({name: argv[1]})[0];
  if (argv.length > 2) {
    if (argv[4] !== "") w.size = [parseInt(argv[4]), parseInt(argv[5])];
    w.position = [parseInt(argv[2]), parseInt(argv[3])];
  }
  var pos = w.position(), sz = w.size();
  return JSON.stringify([pos[0], pos[1], sz[0], sz[1]]);
}
"""


def _osascript(script, *args):
    out = run(["osascript", "-l", "JavaScript", "-e", script] + [str(a) for a in args])
    try:
        return json.loads(out) if out.strip() else None
    except ValueError:
        return None


def _mac_id(wid):
    _mac, pid, title = wid.split(":", 2)
    return int(pid), title


def _mac_windows():
    out = []
    for w in _osascript(_MAC_LIST) or []:
        role, cmd = role_of(w["pid"], w["title"])
        frame = (int(w["x"]), int(w["y"]), int(w["w"]), int(w["h"]))
        x, y, ww, hh = _mac_to_layout(role, frame)
        entry = {"id": "mac:%d:%s" % (w["pid"], w["title"]), "pid": w["pid"],
                 "x": x, "y": y, "w": ww, "h": hh, "frame": frame,
                 "title": w["title"], "role": role, "cmd": cmd}
        if role == "subtitles":
            entry["look"] = _mac_look(w["pid"])
        out.append(entry)
    return out


def _mac_look(pid):
    """The caption box's look: on macOS it keeps it in a file named for its
    process (subtitles.look_file()), there being no X11 property to use."""
    import tempfile
    try:
        with open(os.path.join(tempfile.gettempdir(), "nsts-subtitles-%d.look" % pid)) as fh:
            return fh.read().strip()
    except OSError:
        return ""


def _mac_offset(role):
    """The frame offset a layout carries for this window: Marco's for a
    titled one, none for the caption box (untitled on Linux)."""
    return (0, 0) if role == "subtitles" else MARCO_FRAME_OFFSET


def _mac_role(wid):
    pid, title = _mac_id(wid)
    return role_of(pid, title)[0]


def _mac_to_layout(role, frame):
    """A whole window in points -> a layout's (x, y, w, h)."""
    fx, fy, fw, fh = frame
    dx, dy = _mac_offset(role)
    return (int(round(fx * MAC_UNIT + dx)), int(round((fy + MAC_TITLE_BAR) * MAC_UNIT + dy)),
            int(round(fw * MAC_UNIT)), int(round((fh - MAC_TITLE_BAR) * MAC_UNIT)))


def _mac_from_layout(role, x, y, w=None, h=None):
    """A layout's (x, y, w, h) -> the whole window in points; w and h stay
    None when not given."""
    dx, dy = _mac_offset(role)
    fx = int(round((x - dx) / float(MAC_UNIT)))
    fy = int(round((y - dy) / float(MAC_UNIT) - MAC_TITLE_BAR))
    fw = int(round(w / float(MAC_UNIT))) if w else None
    fh = int(round(h / float(MAC_UNIT) + MAC_TITLE_BAR)) if h else None
    return fx, fy, fw, fh


def _mac_geometry(wid):
    frame = _mac_frame(wid)
    return None if frame is None else _mac_to_layout(_mac_role(wid), frame)


def _mac_place(wid, x, y, w=None, h=None, verbose=False):
    """place() in a layout's units: True, None if gone, else how far out, in
    those units."""
    fx, fy, fw, fh = _mac_from_layout(_mac_role(wid), x, y, w, h)
    ok = _mac_place_frame(wid, fx, fy, fw, fh, verbose)
    if ok is True or ok is None:
        return ok
    return (ok[0] * MAC_UNIT, ok[1] * MAC_UNIT)


def _mac_legacy(layout, here):
    """Does this layout hold whole windows in points, as macOS layouts did
    before they were made portable?  Compared with the windows on screen:
    their widths in points against the file's -- about 1 for an old file,
    about MAC_UNIT for a layout."""
    ratios = []
    for want in layout.get("windows", []):
        got = here.get(want.get("role")) or []
        if got and want.get("w") and got[0].get("frame") and got[0]["frame"][2]:
            ratios.append(float(want["w"]) / got[0]["frame"][2])
    if not ratios:
        return False
    ratios.sort()
    return ratios[len(ratios) // 2] < (1.0 + MAC_UNIT) / 2.0


def _mac_frame(wid, x=None, y=None, w=None, h=None):
    """The whole window in points, moved and sized first if asked."""
    pid, title = _mac_id(wid)
    extra = [] if x is None else [x, y, "" if w is None else w, "" if h is None else h]
    got = _osascript(_MAC_WINDOW, pid, title, *extra)
    return tuple(int(v) for v in got) if got else None


def _mac_place_frame(wid, x, y, w=None, h=None, verbose=False):
    """As place(), for the whole window in points: True when it is where it
    was asked to be, None if it has gone, else how far out it finished.
    macOS may pull a window back onto the screen, out from under the menu bar
    or the Dock, so it is measured, not assumed."""
    now = None
    for attempt in range(3):
        now = _mac_frame(wid, x, y, w, h)
        if now is None:
            return None
        if verbose:
            print("    try %d: asked %d,%d got %d,%d" % (attempt + 1, x, y, now[0], now[1]))
        if abs(now[0] - x) <= 1 and abs(now[1] - y) <= 1:
            return True
        time.sleep(0.2)
    return (x - now[0], y - now[1])


# WSLg.  Its window manager (Weston's) keeps no _NET_CLIENT_LIST, so wmctrl
# can list nothing -- "Cannot get client list properties" -- and every window
# was "not on screen".  xdotool finds them without it; what it finds is Tk's
# wrapper and Qt's top level, the windows wmctrl names elsewhere, and both
# carry _NET_WM_PID (Tk's from claim()).  Moving and measuring were never
# wmctrl's, so only the listing needs another source.  Used only when the
# property is missing, so a desktop that keeps it takes the path it always did.
#
# WSLg HONOURS A PLACE ONLY INSIDE A MONITOR'S WORK AREA, first placement or
# move alike, and puts the window somewhere near the top left otherwise.  Its
# idea of the monitors follows Windows', and a KVM switch (the monitors going
# away and coming back) has left it with one monitor and a 1024x768 work area,
# every place outside that ignored, until the display changed again -- the
# switch back restored it.


# THE OFFSET A LAYOUT'S NUMBERS CARRY for a decorated window: what xdotool
# adds to the client's position on the desktop the layouts are made on --
# MATE's Marco, theme Mint-Y, scale 2 -- where the client sits 22,80 inside
# its frame window (a 20-px invisible resize border, then a 2-px border and a
# 60-px title bar).  Weston's is 38,59 (a 32-px invisible margin, a 6-px
# border, a 27-px title bar), and with that a Linux layout put every decorated
# window 21 px lower and 16 px further left on WSL, over the caption box they
# clear on Linux.  An undecorated or override-redirect window's is 0,0 on
# Marco, Weston's 32,32.
#
# SCALE 2 ONLY: the layouts are made at scale 2.  A layout saved on a scale-1
# MATE desktop carries 11,40 (a 10-px invisible border, then 1 and 30) and
# would restore 11,40 off on WSL.
#
# Measured on Marco by the Linux yaGPC2 Claude session, 2026-09-29: a Tk
# window on Xvfb under marco, cross-checked against a window on Ron's
# desktop.  Weston's from xwininfo on WSLg.
MARCO_FRAME_OFFSET = (22, 80)

# Set once windows() has had to list without a client list -- WSLg -- and
# read by geometry().  Never set on a desktop that keeps the list.  So
# windows() must run before geometry() is trusted on WSL; every flow here
# (show, save, restore, place) lists first.
_WESTON = False


# WSLg's OWN SCALE.  At a whole-number Windows scaling -- 200%, 300% -- WSLg
# scales Linux windows itself: X measures in units of that many real pixels
# (two 3840x2160 monitors are a 3840x1080 X desktop at 200%) and every window
# is drawn that much larger.  At 100% or 150% it scales nothing.  A layout's
# numbers are real pixels, as on Linux, so on WSLg they are divided by the
# scale going to X and multiplied coming back.  Read from WSLg's log, whose
# latest monitor layout gives each monitor's scale; cached by the log's size,
# which changes only when something is written to it.
WESTON_LOG = "/mnt/wslg/weston.log"
_scale_cache = (None, 1)


def wslg_output_scale():
    """1 when WSLg scales nothing, N when every monitor is at N, 0 when the
    monitors differ (unsupported: X's coordinates are then irregular)."""
    global _scale_cache
    try:
        st = os.stat(WESTON_LOG)
    except OSError:
        return 1
    # By inode AND size: a restarted WSLg writes a new log, which could
    # happen to be as long as the old one.
    size = (st.st_ino, st.st_size)
    if _scale_cache[0] == size:
        return _scale_cache[1]
    try:
        with open(WESTON_LOG, errors="replace") as fh:
            text = fh.read()
    except OSError:
        return 1
    i = text.rfind("disp_monitor_validate_and_compute_layout:---OUTPUT---")
    scales = {}
    if i >= 0:
        for line in text[i:].splitlines()[1:60]:
            m = re.search(r"rdpMonitor\[(\d+)\]: scale:(\d+), clientScale", line)
            if m:
                scales[m.group(1)] = int(m.group(2))
    vals = set(scales.values())
    s = vals.pop() if len(vals) == 1 else (1 if not vals else 0)
    _scale_cache = (size, s)
    return s


def _xscale():
    """The factor between X's units and real pixels on this path."""
    s = wslg_output_scale() if _WESTON else 1
    return s if s >= 1 else 1


def nudge(wid):
    """Resize a window by one X pixel and back -- which makes WSLg show it
    again after a monitor change (see simulatePASS.py).  In X's own units,
    whatever the scale."""
    if MAC or WIN:
        return False            # a WSLg fault; nothing to cure elsewhere
    g = dict(re.findall(r"^(\w+)=(-?\d+)$",
                        run(["xdotool", "getwindowgeometry", "--shell", wid]), re.M))
    if "WIDTH" not in g:
        return False
    w, h = g["WIDTH"], g["HEIGHT"]
    run(["xdotool", "windowsize", wid, str(int(w) + 1), h], timeout=5)
    time.sleep(0.1)
    run(["xdotool", "windowsize", wid, w, h], timeout=5)
    return True


def _undecorated(wid):
    """Has the window asked for no frame (_MOTIF_WM_HINTS, decorations off)?"""
    # Decimal on WSLg ("2, 0, 0, 0, 0"), hex elsewhere ("0x2, 0x0, ...").
    num = r"((?:0x)?[0-9a-fA-F]+)"
    m = re.search(r"=\s*%s,\s*%s,\s*%s" % (num, num, num),
                  run(["xprop", "-id", wid, "_MOTIF_WM_HINTS"]))
    return bool(m) and (int(m.group(1), 0) & 2) != 0 and int(m.group(3), 0) == 0


def _absolute_xy(wid):
    """Where the window itself is on the screen, as xwininfo has it, and
    whether it is override-redirect -- never framed by any window manager
    (subtitles.py --no-taskbar), and carrying no Motif hints to say so."""
    text = run(["xwininfo", "-id", wid])
    x = re.search(r"Absolute upper-left X:\s*(-?\d+)", text)
    y = re.search(r"Absolute upper-left Y:\s*(-?\d+)", text)
    if not (x and y):
        return None
    return int(x.group(1)), int(y.group(1)), "Override Redirect State: yes" in text


def _no_client_list():
    # BY WHAT IS THERE, not by how its absence is worded: xprop says "not
    # found" once some client has interned the atom, and "no such atom on any
    # window" before (PASS-IDLE, measured on a bare Xvfb).
    return "_NET_CLIENT_LIST(WINDOW)" not in run(["xprop", "-root", "_NET_CLIENT_LIST"])


def _listing_without_wmctrl():
    """wmctrl -lpG's lines, built from xdotool: id, desktop, pid, x, y, w, h,
    machine and title.  The position and size are placeholders -- windows()
    measures every window for itself -- and so is the desktop."""
    lines = []
    # BY NAME AND BY CLASS, merged.  SDL sets WM_NAME only as UTF8_STRING,
    # which xdotool's --name search does not match, so the virtual hand
    # controllers' window was missing from this list (WSL-integration,
    # 2026-10-01); --class finds it, and every Tk window either way.
    wids = []
    for how in ("--name", "--class"):
        for wid in run(["xdotool", "search", "--onlyvisible", how, "."]).split():
            if wid not in wids:
                wids.append(wid)
    for wid in wids:
        pid = run(["xdotool", "getwindowpid", wid]).strip()
        title = run(["xdotool", "getwindowname", wid]).strip()
        lines.append("0x%08x 0 %s 0 0 0 0 N/A %s"
                     % (int(wid), pid if pid.isdigit() else "0", title))
    return "\n".join(lines)


def windows():
    """Every managed window: {id, pid, x, y, w, h, title, role, cmd}."""
    if MAC:
        return _mac_windows()
    if WIN:
        # NOT WSLg's: a WSL run's windows are ordinary Windows top-levels on
        # the same desktop, titled "... (Ubuntu)", and a native save or
        # restore was taking them as its own (WSL-integration and
        # Win11-native, 2026-10-02).  They belong to the run inside WSL.
        return [w for w in _win_windows() if not WSLG_SUFFIX.search(w.get("title", ""))]
    out = []
    listing = run(["wmctrl", "-lpG"])
    if not listing.strip() and _no_client_list():
        global _WESTON
        _WESTON = True
        listing = _listing_without_wmctrl()
    for line in listing.splitlines():
        parts = line.split(None, 7)
        if len(parts) < 8:
            continue
        wid, _desk, pid, x, y, w, h, rest = parts
        # the last field is the client's machine and then the title; the
        # machine is "N/A" for a window that does not say (Tk's do not).
        host, _, title = rest.partition(" ")
        if host not in ("N/A", HOSTNAME):
            title = rest
        title = title.strip()
        if title in ("Desktop", "Bottom Panel", "Top Panel", ""):
            continue
        pid = int(pid)
        role, cmd = role_of(pid, title)
        entry = {"id": wid, "pid": pid, "x": int(x), "y": int(y),
                 "w": int(w), "h": int(h), "title": title, "role": role, "cmd": cmd}
        # WHERE IT REALLY IS, asked of the same tool that moves it.  wmctrl
        # lists the window the desktop manages, which for an undecorated
        # window (subtitles.py) is a wrapper that is not itself placed on
        # screen: it reported the caption box at 7020,3984 -- twice the real
        # position, and off a 7680x2160 screen -- while xdotool had 3510,1992.
        # Saving one and restoring with the other put the box nowhere near.
        real = geometry(wid)
        if real is not None:
            entry.update({"x": real[0], "y": real[1], "w": real[2], "h": real[3]})
        if role == "subtitles":
            entry["look"] = look_of(wid)
        out.append(entry)
    return out


def look_of(wid):
    """subtitles.py keeps its own look -- font, size, colours, alignment -- on
    its window as _NSTS_SUBTITLES, so a layout can be saved with it."""
    text = run(["xprop", "-id", wid, "_NSTS_SUBTITLES"])
    m = re.search(r'_NSTS_SUBTITLES.*?=\s*"(.*)"\s*$', text, re.S)
    return m.group(1).strip() if m else ""


def geometry(wid):
    """Where the window manager actually has it now."""
    if MAC:
        return _mac_geometry(wid)
    if WIN:
        return _win_geometry(wid)
    text = run(["xdotool", "getwindowgeometry", "--shell", wid])
    g = dict(re.findall(r"^(\w+)=(-?\d+)$", text, re.M))
    if not g:
        return None
    # xdotool's X and Y are the window's position plus its offset inside the
    # window manager's frame, so a saved place carries the saving desktop's
    # frame.  On WSLg the window is measured where it really is and given
    # MARCO's offset instead of Weston's, so that one layout file means the
    # same on both -- see MARCO_FRAME_OFFSET.
    # At a WSLg scale, X's figures are multiplied up to real pixels first --
    # Marco's offset is in real pixels already.
    if _WESTON:
        xy = _absolute_xy(wid)
        if xy is not None:
            s = _xscale()
            frameless = xy[2] or _undecorated(wid)
            dx, dy = (0, 0) if frameless else MARCO_FRAME_OFFSET
            return (xy[0] * s + dx, xy[1] * s + dy,
                    int(g["WIDTH"]) * s, int(g["HEIGHT"]) * s)
    return int(g["X"]), int(g["Y"]), int(g["WIDTH"]), int(g["HEIGHT"])


def place(wid, x, y, w=None, h=None, verbose=False):
    """Move (and optionally resize), correcting for what the frame does.

    Without xdotool's --sync: that waits for the window manager to confirm,
    and waits for ever when the move is refused, which hung a whole run.  The
    loop below measures for itself instead."""
    if MAC:
        return _mac_place(wid, x, y, w, h, verbose)
    if WIN:
        return _win_place(wid, x, y, w, h, verbose)
    # x, y, w, h are real pixels; xdotool asks in X's units, which on a
    # scaled WSLg are s of them -- so the asks are divided by s, and a place
    # within s pixels of the target is as close as X can put it.
    s = _xscale()
    if w and h:
        run(["xdotool", "windowsize", wid, str(int(round(w / float(s)))),
             str(int(round(h / float(s))))], timeout=5)
        time.sleep(0.15)
    ask_x, ask_y = (int(round(x / float(s))), int(round(y / float(s)))) if s > 1 else (x, y)
    dx = dy = None
    for attempt in range(5):
        run(["xdotool", "windowmove", wid, str(ask_x), str(ask_y)], timeout=5)
        time.sleep(0.25)
        now = geometry(wid)
        if now is None:
            return None                # gone; nothing to say about it
        dx, dy = x - now[0], y - now[1]
        if verbose:
            print("    try %d: asked %d,%d got %d,%d (want %d,%d)"
                  % (attempt + 1, ask_x, ask_y, now[0], now[1], x, y))
        if abs(dx) < s and abs(dy) < s:
            return True
        # off by that much: ask for less
        ask_x, ask_y = ask_x + int(round(dx / float(s))), ask_y + int(round(dy / float(s)))
    return (dx, dy)                    # how far out it finished


def save_layout(path, everything=False, only_ids=None, log=print, only_pids=None,
                merge=False):
    """Write where the windows are now.  everything keeps unrecognised ones;
    only_ids limits it to those windows, only_pids to those processes' (see
    descendants()).  Returns how many were saved.

    merge: ADD TO THE FILE rather than replace it -- windows on screen now
    replace their own entries, the file's other entries are kept.  The
    panels' windows appear only with the OPS that needs them, so no one
    moment has all of them up to save (owner, 2026-10-02)."""
    keep = [w for w in windows()
            if (everything or not w["role"].startswith("other:"))
            and (only_ids is None or w["id"] in only_ids)
            and (only_pids is None or w["pid"] in only_pids)]
    entries = [{k: w[k] for k in ("role", "x", "y", "w", "h", "title", "look") if k in w}
               for w in keep]
    kept = 0
    if merge and os.path.isfile(path):
        with open(path) as fh:
            old = json.load(fh).get("windows", [])
        now = {e["role"] for e in entries}
        rest = [e for e in old if e.get("role") not in now]
        kept = len(rest)
        entries += rest
    layout = {"saved": time.strftime("%Y-%m-%d %H:%M:%S"),
              "windows": sorted(entries, key=lambda e: e["role"])}
    with open(path, "w") as fh:
        json.dump(layout, fh, indent=2)
        fh.write("\n")
    log("saved %d windows to %s%s" % (len(keep), path,
                                      " (and kept %d not on screen)" % kept if merge else ""))
    return len(keep)


WSLG_SUFFIX = re.compile(r" \([A-Za-z][\w.-]*\)$")   # WSLg's " (Ubuntu)"
PORT_BASE_ARG = re.compile(r"--port-base[ =](\d+)")


def port_base_of(cmd):
    """The --port-base on a command line, or None."""
    m = PORT_BASE_ARG.search(cmd or "")
    return int(m.group(1)) if m else None


def _scope(args, refuse):
    """THE WINDOWS OF ONE SIMULATION.  The manager's own Save and Restore are
    limited to its run's processes, but this command line was not: a save
    and restore on one port base swept up a live run on another and moved
    its windows (Win11-native, 2026-10-02).  --port-base limits it to the
    processes started with that port base; without it, more than one
    simulation on screen is reported -- and a restore refused."""
    ws = windows()
    if args.port_base is not None:
        return {w["pid"] for w in ws if port_base_of(w.get("cmd")) == args.port_base}
    bases = sorted({b for b in (port_base_of(w.get("cmd")) for w in ws) if b is not None})
    if len(bases) > 1:
        msg = ("windows of %d simulations are on screen (port bases %s); "
               "give --port-base to say which" % (len(bases), ", ".join(map(str, bases))))
        if refuse:
            raise SystemExit("windowLayout: " + msg + " -- nothing moved")
        print("windowLayout: warning: " + msg)
    return None


def cmd_save(args):
    save_layout(args.file, everything=args.all, merge=args.merge,
                only_pids=_scope(args, refuse=False))
    with open(args.file) as fh:
        layout = json.load(fh)
    for w in layout["windows"]:
        print("   %-12s %5d,%-5d %4dx%-4d  %s" % (w["role"], w["x"], w["y"],
                                                  w["w"], w["h"], w.get("title", "")[:40]))
        if w.get("look"):
            print("   %-12s %s" % ("", w["look"]))
    return 0


def window_ids():
    """Every window id on screen now.  A launcher takes this before it starts
    anything, so it can place its OWN windows and not another run's."""
    return {w["id"] for w in windows()}


def has_role(role, only_ids=None):
    """Is a window of that name on screen now?  For a launcher deciding
    whether it still has to start the program.  only_ids narrows the question
    to that launcher's own windows, so another simulation's do not answer it."""
    return any(w["role"] == role and (only_ids is None or w["id"] in only_ids)
               for w in windows())


def roles_in(path):
    """The names a layout file mentions."""
    with open(path) as fh:
        return [w["role"] for w in json.load(fh)["windows"]]


def look_in(path, role="subtitles"):
    """The look saved for that window, as a list of options, or []."""
    with open(path) as fh:
        for w in json.load(fh)["windows"]:
            if w["role"] == role and w.get("look"):
                return w["look"].split()
    return []


def restore_layout(path, with_sizes=True, verbose=False, log=print, only_ids=None,
                   only_pids=None, only_roles=None):
    """Put the windows where the file says.  only_ids, if given, is the set of
    window ids that may be moved; only_pids the set of processes whose windows
    may be -- see descendants(), which is how one simulation is kept from
    dragging another's windows about; only_roles the roles that may be, the
    rest of the file being left alone -- a window started late is placed
    without moving the ones already arranged.  Returns (placed, missing,
    inexact)."""
    with open(path) as fh:
        layout = json.load(fh)
    here = {}
    for w in windows():
        if only_ids is not None and w["id"] not in only_ids:
            continue
        if only_pids is not None and w["pid"] not in only_pids:
            continue
        here.setdefault(w["role"], []).append(w)
    # AN OLD macOS FILE -- whole windows in points -- is told by its sizes:
    # about the windows' own in points, where a layout's are twice that.
    legacy = MAC and _mac_legacy(layout, here)
    if legacy:
        log("   (an older macOS layout, in points: placed as it was saved)")
    done = missing = failed = 0
    for want in layout["windows"]:
        role = want["role"]
        if only_roles is not None and role not in only_roles:
            continue
        got = here.get(role)
        if not got:
            log("   %-12s not on screen" % role)
            missing += 1
            continue
        if len(got) > 1:
            log("   %-12s %d windows have this name; taking %s (%s)"
                % (role, len(got), got[0]["id"], got[0]["title"][:40]))
        w = got.pop(0)
        # SIZE AS WELL AS PLACE, for every window.  It used to be the caption
        # box alone; but the windows a layout exists to protect are all
        # resizable by hand, and a layout restored after a stray drag has to
        # undo the size along with the position or it has not undone anything.
        size = ((want.get("w"), want.get("h")) if with_sizes else (None, None))
        if legacy:
            ok = _mac_place_frame(w["id"], want["x"], want["y"], size[0], size[1], verbose)
        else:
            ok = place(w["id"], want["x"], want["y"], size[0], size[1], verbose)
        if ok is True:
            note = ""
        elif ok is None:
            note = "  (the window went away)"
        else:
            # SAY ONLY WHAT IS KNOWN: the window manager moved it.  A window
            # straddling two monitors is one reason; a work area that has
            # shrunk under it -- WSLg after a display change, down to one
            # monitor -- is another, and blaming the first misled
            # (WSL-integration, 2026-10-01).
            note = ("  (ended %+d,%+d from there -- the window manager moved it: "
                    "off its work area, or across two monitors?)" % (-ok[0], -ok[1]))
        log("   %-12s -> %d,%d%s%s" % (role, want["x"], want["y"],
                                       " %dx%d" % size if size[0] else "", note))
        done += 1
        failed += 0 if ok is True else 1
    log("placed %d window(s)%s%s" % (done,
                                     ", %d not running" % missing if missing else "",
                                     ", %d inexact" % failed if failed else ""))
    return done, missing, failed


def cmd_restore(args):
    restore_layout(args.file, not args.no_sizes, args.verbose,
                   only_pids=_scope(args, refuse=True))
    return 0


def cmd_show(args):
    if args.file:
        with open(args.file) as fh:
            layout = json.load(fh)
        print("%s, saved %s" % (args.file, layout.get("saved", "?")))
        rows = [(w["role"], w["x"], w["y"], w["w"], w["h"], w["title"]) for w in layout["windows"]]
    else:
        rows = [(w["role"], w["x"], w["y"], w["w"], w["h"], w["title"])
                for w in sorted(windows(), key=lambda w: w["role"])
                if not w["role"].startswith("other:") or args.all]
    for role, x, y, w, h, title in rows:
        print("   %-12s %5d,%-5d %4dx%-4d  %s" % (role, x, y, w, h, title[:45]))
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0],
                                 epilog=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="what")
    s = sub.add_parser("save", help="write the current placement to a file")
    s.add_argument("file")
    s.add_argument("--all", action="store_true", help="unrecognised windows too")
    s.add_argument("--merge", action="store_true",
                   help="add to the file: the windows on screen replace their own "
                        "entries, its others are kept")
    s.add_argument("--port-base", type=int, default=None,
                   help="only that simulation's windows")
    s.set_defaults(func=cmd_save)
    r = sub.add_parser("restore", help="put the windows back where a file says")
    r.add_argument("file")
    r.add_argument("--with-sizes", action="store_true",
                   help="accepted and ignored: sizes are restored anyway")
    r.add_argument("--no-sizes", action="store_true",
                   help="move the windows without resizing them")
    r.add_argument("--verbose", action="store_true", help="show each move and what came of it")
    r.add_argument("--port-base", type=int, default=None,
                   help="only that simulation's windows (required when more than one is up)")
    r.set_defaults(func=cmd_restore)
    h = sub.add_parser("show", help="what is on screen now, or what a file holds")
    h.add_argument("file", nargs="?")
    h.add_argument("--all", action="store_true", help="unrecognised windows too")
    h.set_defaults(func=cmd_show)
    args = ap.parse_args(argv)
    if not args.what:
        ap.print_help()
        return 1
    for tool in (("osascript",) if MAC else () if WIN else ("wmctrl", "xdotool")):
        if not any(os.access(os.path.join(p, tool), os.X_OK)
                   for p in os.environ.get("PATH", "").split(":")):
            sys.exit("windowLayout: %s is not installed" % tool)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
