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

SIZES.  Only the caption box is resized: the displays and the panel size
themselves from --size, and forcing a different size on them would not scale
what they draw.  'restore --with-sizes' resizes everything in the file.

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

# Tk tells nobody its process id, so its windows are named by title instead.
TITLE_ROLES = [
    (re.compile(r"^Subtitles$"), "subtitles"),
    (re.compile(r"^CAM$"), "cam"),
    (re.compile(r"^Panels O6\b"), "panel"),
    (re.compile(r"^GPC discrete panel"), "discretepanel"),
    (re.compile(r"^Manager\b"), "manager"),
    (re.compile(r"^([123])$"), lambda m: "kybd%s" % m.group(1)),
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
RESIZE_BY_DEFAULT = ("subtitles",)


HOSTNAME = os.uname().nodename


def run(cmd, timeout=10):
    """Never wait on a window that will not answer: every call is bounded."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.SubprocessError):
        return ""


def cmdline(pid):
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
    for d in os.listdir("/proc"):
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
    (measured: frame 0xbf3481, listed window 0x05e00004)."""
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


def windows():
    """Every managed window: {id, pid, x, y, w, h, title, role, cmd}."""
    out = []
    for line in run(["wmctrl", "-lpG"]).splitlines():
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


def restore_layout(path, with_sizes=False, verbose=False, log=print, only_ids=None,
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
        size = ((want["w"], want["h"]) if (with_sizes or role in RESIZE_BY_DEFAULT)
                else (None, None))
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
    restore_layout(args.file, args.with_sizes, args.verbose)
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
                   help="resize every window, not just the caption box")
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
    for tool in ("wmctrl", "xdotool"):
        if not any(os.access(os.path.join(p, tool), os.X_OK)
                   for p in os.environ.get("PATH", "").split(":")):
            sys.exit("windowLayout: %s is not installed" % tool)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
