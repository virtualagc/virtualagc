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
    (re.compile(r"^CAM$"), "cam"),
    # BOTH TITLES THE PANEL HAS WORN.  It is "Panel" now -- the task bar shows
    # a few characters and a long title made every button look alike -- but a
    # layout saved before that, or an older copy of panelO6.py, still says
    # "Panels O6, ...".
    (re.compile(r"^Panel$|^Panels O6\b"), "panel"),
    (re.compile(r"^GPC discrete panel"), "discretepanel"),
    (re.compile(r"^Manager\b"), "manager"),
    (re.compile(r"^([123])$"), lambda m: "kybd%s" % m.group(1)),
    # A DISPLAY BY ITS OWN NAME, now that its title is just "CRT1".  The
    # command line is tried first and normally answers; this is the fallback
    # for a window whose process cannot be read.
    (re.compile(r"^(CRT|CDR|PLT|MFD|AFD)(\d)$", re.I),
     lambda m: m.group(0).lower()),
]
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
]


HOSTNAME = os.uname().nodename


def run(cmd, timeout=10):
    """Never wait on a window that will not answer: every call is bounded."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def cmdline(pid):
    if not os.path.isdir("/proc"):
        return procinfo.cmdline(pid)            # macOS
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
    inherited arrow is 24 px beside Tk's and Qt's own themed 48."""
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


def role_of(pid, title):
    cmd = cmdline(pid) if pid else ""
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
        entry = {"id": "mac:%d:%s" % (w["pid"], w["title"]), "pid": w["pid"],
                 "x": int(w["x"]), "y": int(w["y"]), "w": int(w["w"]), "h": int(w["h"]),
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


def _mac_geometry(wid, x=None, y=None, w=None, h=None):
    pid, title = _mac_id(wid)
    extra = [] if x is None else [x, y, "" if w is None else w, "" if h is None else h]
    got = _osascript(_MAC_WINDOW, pid, title, *extra)
    return tuple(int(v) for v in got) if got else None


def _mac_place(wid, x, y, w=None, h=None, verbose=False):
    """As place(): True when it is where it was asked to be, None if it has
    gone, else how far out it finished.  macOS may pull a window back onto
    the screen or out from under the menu bar, so it is measured, not
    assumed."""
    now = None
    for attempt in range(3):
        now = _mac_geometry(wid, x, y, w, h)
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
    for wid in run(["xdotool", "search", "--onlyvisible", "--name", "."]).split():
        pid = run(["xdotool", "getwindowpid", wid]).strip()
        title = run(["xdotool", "getwindowname", wid]).strip()
        lines.append("0x%08x 0 %s 0 0 0 0 N/A %s"
                     % (int(wid), pid if pid.isdigit() else "0", title))
    return "\n".join(lines)


def windows():
    """Every managed window: {id, pid, x, y, w, h, title, role, cmd}."""
    if MAC:
        return _mac_windows()
    out = []
    listing = run(["wmctrl", "-lpG"])
    if not listing.strip() and _no_client_list():
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
    text = run(["xdotool", "getwindowgeometry", "--shell", wid])
    g = dict(re.findall(r"^(\w+)=(-?\d+)$", text, re.M))
    if not g:
        return None
    return int(g["X"]), int(g["Y"]), int(g["WIDTH"]), int(g["HEIGHT"])


def place(wid, x, y, w=None, h=None, verbose=False):
    """Move (and optionally resize), correcting for what the frame does.

    Without xdotool's --sync: that waits for the window manager to confirm,
    and waits for ever when the move is refused, which hung a whole run.  The
    loop below measures for itself instead."""
    if MAC:
        return _mac_place(wid, x, y, w, h, verbose)
    if w and h:
        run(["xdotool", "windowsize", wid, str(w), str(h)], timeout=5)
        time.sleep(0.15)
    ask_x, ask_y = x, y                # x, y stay the target; the ask moves
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
        if dx == 0 and dy == 0:
            return True
        ask_x, ask_y = ask_x + dx, ask_y + dy    # off by that much: ask for less
    return (dx, dy)                    # how far out it finished


def save_layout(path, everything=False, only_ids=None, log=print, only_pids=None):
    """Write where the windows are now.  everything keeps unrecognised ones;
    only_ids limits it to those windows, only_pids to those processes' (see
    descendants()).  Returns how many were saved."""
    keep = [w for w in windows()
            if (everything or not w["role"].startswith("other:"))
            and (only_ids is None or w["id"] in only_ids)
            and (only_pids is None or w["pid"] in only_pids)]
    layout = {"saved": time.strftime("%Y-%m-%d %H:%M:%S"),
              "windows": [{k: w[k] for k in ("role", "x", "y", "w", "h", "title", "look")
                           if k in w}
                          for w in sorted(keep, key=lambda w: w["role"])]}
    with open(path, "w") as fh:
        json.dump(layout, fh, indent=2)
        fh.write("\n")
    log("saved %d windows to %s" % (len(keep), path))
    return len(keep)


def cmd_save(args):
    ws = windows()
    keep = [w for w in ws if not w["role"].startswith("other:") or args.all]
    layout = {"saved": time.strftime("%Y-%m-%d %H:%M:%S"),
              "windows": [{k: w[k] for k in ("role", "x", "y", "w", "h", "title", "look")
                           if k in w}
                          for w in sorted(keep, key=lambda w: w["role"])]}
    with open(args.file, "w") as fh:
        json.dump(layout, fh, indent=2)
        fh.write("\n")
    print("saved %d windows to %s" % (len(keep), args.file))
    for w in layout["windows"]:
        print("   %-12s %5d,%-5d %4dx%-4d  %s" % (w["role"], w["x"], w["y"],
                                                  w["w"], w["h"], w["title"][:40]))
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
                   only_pids=None):
    """Put the windows where the file says.  only_ids, if given, is the set of
    window ids that may be moved; only_pids the set of processes whose windows
    may be -- see descendants(), which is how one simulation is kept from
    dragging another's windows about.  Returns (placed, missing, inexact)."""
    with open(path) as fh:
        layout = json.load(fh)
    here = {}
    for w in windows():
        if only_ids is not None and w["id"] not in only_ids:
            continue
        if only_pids is not None and w["pid"] not in only_pids:
            continue
        here.setdefault(w["role"], []).append(w)
    done = missing = failed = 0
    for want in layout["windows"]:
        role = want["role"]
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
        ok = place(w["id"], want["x"], want["y"], size[0], size[1], verbose)
        if ok is True:
            note = ""
        elif ok is None:
            note = "  (the window went away)"
        else:
            note = ("  (ended %+d,%+d from there -- a window that would straddle two "
                    "monitors is pushed back onto one)" % (-ok[0], -ok[1]))
        log("   %-12s -> %d,%d%s%s" % (role, want["x"], want["y"],
                                       " %dx%d" % size if size[0] else "", note))
        done += 1
        failed += 0 if ok is True else 1
    log("placed %d window(s)%s%s" % (done,
                                     ", %d not running" % missing if missing else "",
                                     ", %d inexact" % failed if failed else ""))
    return done, missing, failed


def cmd_restore(args):
    restore_layout(args.file, not args.no_sizes, args.verbose)
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
    s.set_defaults(func=cmd_save)
    r = sub.add_parser("restore", help="put the windows back where a file says")
    r.add_argument("file")
    r.add_argument("--with-sizes", action="store_true",
                   help="accepted and ignored: sizes are restored anyway")
    r.add_argument("--no-sizes", action="store_true",
                   help="move the windows without resizing them")
    r.add_argument("--verbose", action="store_true", help="show each move and what came of it")
    r.set_defaults(func=cmd_restore)
    h = sub.add_parser("show", help="what is on screen now, or what a file holds")
    h.add_argument("file", nargs="?")
    h.add_argument("--all", action="store_true", help="unrecognised windows too")
    h.set_defaults(func=cmd_show)
    args = ap.parse_args(argv)
    if not args.what:
        ap.print_help()
        return 1
    for tool in (("osascript",) if MAC else ("wmctrl", "xdotool")):
        if not any(os.access(os.path.join(p, tool), os.X_OK)
                   for p in os.environ.get("PATH", "").split(":")):
            sys.exit("windowLayout: %s is not installed" % tool)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
