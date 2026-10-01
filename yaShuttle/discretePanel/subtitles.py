#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""A caption box for demonstration videos: a borderless window that shows
whatever text arrives on the simulation's bus, and nothing else.

    python3 subtitles.py                      # port base 6900, bottom centre
    python3 subtitles.py --port-base 27000 --font-size 32
    python3 subtitles.py --geometry 1200x140+360+900
    python3 subtitles.py --align left          # left, center (default) or right
    python3 subtitles.py --edit                # type into it to try sizes

Scripts drive it: a crew script line '<seconds> subtitle text ...' (or a
simulatePASS.py --keys line '<seconds> SUBTITLE text ...') replaces the
caption, and the same command with no text clears it.  simulatePASS.py starts
this program by itself when a script contains a subtitle line.

THE BUS.  One UDP datagram per caption, UTF-8, on the discrete bus's multicast
group at port base + 90 (SUBTITLE_OFFSET).  An empty or all-blank datagram
clears the box; the two characters backslash-n in the text start a new line.
A caption may begin with <left>, <center> (or <centre>) or <right> to align
that caption alone; one without uses --align.
Anything can send one:

    python3 -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); \\
      s.sendto(b'OPS 2 transition', ('239.255.1.1', 6990))"

THE BOX STAYS PUT.  Its place and size are the ones it was given, and a
caption never changes either: text is wrapped to the width, and a caption with
more lines than the height holds is cut off, not given a bigger box.  A box
that resized and moved itself with every caption was one more thing on the
screen for a viewer to follow, and a recording shows it doing so.  The place
and size change only when someone changes them: by dragging it (with --edit),
or by a layout being restored (windowLayout.py, the manager's Restore,
simulatePASS.py --layout).  So choose a height for the longest caption the
script has.

TRYING SIZES: --edit.  The box takes the keyboard (on Windows, once it is
clicked), so captions can be typed straight into it to find a geometry and
font size that suit a recording:

    typing          the caption (Enter: new line, Backspace, Escape: clear)
    Ctrl + / Ctrl - font size up or down by 2 points
    Ctrl L / E / R  align left, centre or right
    drag            move the box
    Shift-drag      change its width and height
    Ctrl P          print the options that reproduce the box
    Ctrl H          hide or show the cursor (it shows only while the box
                    has the keyboard anyway, so clicking another window
                    hides it for a recording)

After any change of size, place, font size or alignment it prints the
equivalent options -- '--geometry WxH+X+Y --font-size N --align A' -- to
paste into the command line.  Captions from the bus still arrive meanwhile.

THE WINDOW has no title bar.  With --edit it is moved by dragging it with the
left button; without, a click does nothing to it, so a recording cannot
knock it out of place.  The right button offers Clear and Quit, and Ctrl+Q
quits.  It stays
above the other windows so a recording always shows it.  It is an ordinary
window the desktop manages -- listed in the taskbar as "Subtitles" -- that
asks not to be decorated (_MOTIF_WM_HINTS); --no-taskbar makes it an
unmanaged one instead, as it first was, which no window manager can frame
but which the taskbar does not list either (and which may not take the
keyboard for --edit).
"""

import argparse
import os
import queue
import re
import sys
import socket
import struct
import subprocess
import threading
import time
import tkinter as tk
import tkinter.font as tkfont

import discretes as D

SUBTITLE_OFFSET = 90
DEFAULT_W, DEFAULT_H = 1000, 120
BOTTOM_MARGIN = 80
PAD_X, PAD_Y = 16, 8
MIN_W, MIN_H = 200, 40
EDIT_CURSOR = "▌"          # the block shown after typed text in --edit
FOCUS_POLL_MS = 250        # Windows: how often a focused box checks it still is
# --align: how the lines sit against each other (justify) and where the text
# sits in the box (anchor).
ANCHORS = {"left": "w", "center": "center", "right": "e"}
# A caption's own alignment, at its very start: "<left> Loading PASS".
ALIGN_TAG = re.compile(r"<(left|center|centre|right)>\s*", re.IGNORECASE)
GEOMETRY = re.compile(r"^(\d+)x(\d+)([+-]\d+)([+-]\d+)$")


def log(msg):
    print("subtitles: %s" % msg, flush=True)


def subtitle_port():
    return D.PORT_BASE + SUBTITLE_OFFSET


def receiver(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", port))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def send(text, port=None, sock=None):
    """Send one caption (empty text clears).  For other programs to call."""
    own = sock is None
    if own:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                        socket.inet_aton(D.IFACE))
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        sock.sendto(text.encode("utf-8"), (D.GROUP, port or subtitle_port()))
    finally:
        if own:
            sock.close()


# How often the box looks at the desktop's arrangement, and how long that
# must have stayed put before an outside move is believed again (Windows).
SCREEN_POLL_MS = 500
SCREEN_SETTLE_S = 5.0


def virtual_screen():
    """Windows: the whole desktop's extent across every monitor, as (x, y,
    width, height) -- which changes when a monitor goes away or comes back.
    None anywhere else, where nothing here uses it."""
    if sys.platform != "win32":
        return None
    try:
        import ctypes
        m = ctypes.windll.user32.GetSystemMetrics
        return (m(76), m(77), m(78), m(79))    # SM_[XY]VIRTUALSCREEN, SM_C[XY]VIRTUALSCREEN
    except Exception:
        return None


def _user32():
    import ctypes
    from ctypes import wintypes
    user32 = ctypes.WinDLL("user32")
    user32.GetForegroundWindow.restype = wintypes.HWND
    user32.GetAncestor.restype = wintypes.HWND
    user32.GetAncestor.argtypes = [wintypes.HWND, wintypes.UINT]
    user32.SetForegroundWindow.argtypes = [wintypes.HWND]
    return user32


def foreground_window():
    """Windows: the window that has the keyboard.  None anywhere else."""
    if sys.platform != "win32":
        return None
    try:
        return _user32().GetForegroundWindow()
    except (OSError, AttributeError):
        return None


def look_file(pid):
    """Where a caption box on macOS or Windows keeps its look (see
    _publish_look)."""
    import tempfile
    return os.path.join(tempfile.gettempdir(), "nsts-subtitles-%d.look" % pid)


class Subtitles(object):
    def __init__(self, root, args, box, before=None):
        """box: (width, height, x, y).  before: Windows only, the window that
        had the keyboard before this program made one (foreground_window())."""
        self.root = root
        self.args = args
        # The box is kept here rather than read back from the window, which
        # has no size of its own until it is mapped: width, height, left edge
        # and top edge -- all fixed until someone moves or resizes it.
        self.w, self.min_h, self.x, self.top = box
        self.h = None
        self._wm_id = None            # the window the desktop deals with
        self._asked = None            # the geometry this program last set
        # The desktop this box was placed on, and whether it has gone
        # (Windows only; None elsewhere -- see _watch_screens).
        self._screens = self._seen = virtual_screen()
        self._screens_changed = 0.0
        self._displaced = False
        self.align = args.align
        self.text = ""
        root.title("Subtitles")
        if args.no_taskbar:
            root.overrideredirect(True)      # unmanaged: no frame, no taskbar entry
        else:
            # Managed, so the taskbar lists it, but undecorated.  The window
            # manager (Marco, here) reads the hint only when a window is FIRST
            # mapped, so the window stays withdrawn until the hint is on it.
            root.withdraw()
        # NOT ON TOP OF EVERYTHING.  It used to be, and that makes the
        # desktop nearly unusable while a simulation is up: the captions sit
        # over whatever else is being read or typed into.  A caption box is
        # something to glance at, not something that outranks the work.
        root.configure(bg=args.bg)
        try:
            root.attributes("-alpha", args.opacity)
        except tk.TclError:
            pass                              # no compositor: opaque it is
        self.font = tkfont.Font(family=args.font, size=args.font_size, weight="bold")
        self.label = tk.Label(root, text="", fg=args.fg, bg=args.bg, font=self.font,
                              justify=self.align, anchor=ANCHORS[self.align],
                              padx=PAD_X, pady=PAD_Y)
        self.label.pack(fill="both", expand=True)
        # Bound on the toplevel only: its bindings already see the label's
        # events, so binding both ran every handler twice.  Moving it by hand
        # is for --edit; otherwise a stray click in a recording cannot move it.
        if args.edit:
            root.bind("<ButtonPress-1>", self._drag_start)
            root.bind("<B1-Motion>", self._drag)
            root.bind("<ButtonRelease-1>", self._drag_end)
        root.bind("<ButtonPress-3>", self._menu)
        # A move or resize from outside -- a window manager, wmctrl, or
        # windowLayout.py restoring a saved placement -- becomes the box's own
        # idea of where it is, so the next caption does not undo it.
        root.bind("<Configure>", self._configured)
        if args.edit:
            root.bind("<Shift-ButtonPress-1>", self._resize_start)
            root.bind("<Shift-B1-Motion>", self._resize)
        root.bind_all("<Control-q>", lambda _e: root.quit())
        # The typing cursor shows only while it is wanted (Ctrl H) and the box
        # has the keyboard, so it is gone once focus moves to another window.
        self.cursor_wanted = True
        self.focused = False
        self._focus_polling = False
        if args.edit:
            root.bind("<Key>", self._key)
            root.bind("<FocusIn>", lambda _e: self._focus(True))
            root.bind("<FocusOut>", lambda _e: self._focus(False))
        self.popup = tk.Menu(root, tearoff=0)
        self.popup.add_command(label="Clear", command=lambda: self.show(""))
        self.popup.add_command(label="Quit", command=root.quit)
        self.q = queue.Queue()
        self._grab = (0, 0)
        self._moved = False
        self._resize_from = None
        if not args.no_taskbar:
            self._undecorate()               # before anything can map the window
        self.text = args.text or ""
        self._fit()                          # its place and size, once
        self.show(self.text)
        if not args.no_taskbar and (args.edit or not (args.hide_when_empty
                                                      and not self.text.strip())):
            root.deiconify()
        if args.edit:
            if sys.platform == "win32":
                # Windows gives a new window the keyboard as it appears, so
                # the box would start with its cursor; as elsewhere, it starts
                # without the keyboard, and a click on it gives it the keyboard.
                root.after(200, lambda: self._give_keyboard_back(before))
            else:
                root.after(200, root.focus_force)
            log("--edit: type a caption; Ctrl +/- font, Ctrl L/E/R align, "
                "Shift-drag size, Ctrl P options, Ctrl H cursor")
            self._report()
        root.after(300, self._publish_look)
        threading.Thread(target=self._listen, daemon=True).start()
        root.after(50, self._poll)
        if self._screens is not None:
            root.after(SCREEN_POLL_MS, self._watch_screens)

    # -- the monitors going away and coming back (Windows) -------------------
    def _watch_screens(self):
        """HOME AGAIN WHEN THE MONITORS ARE.

        A KVM switch, or a monitor turned off, makes Windows move every window
        onto what is left -- a stand-in display, often at another scale -- and
        put it back when the monitors return.  This box is the one window that
        takes a move from outside as its new home (see _configured) and then
        places ITSELF there with every caption, so it stayed wherever Windows
        had parked it, while every other window went home (2026-09-30).

        So while the desktop is not the one the box was placed on -- or has
        only just changed -- an outside move is not taken as a new home; and
        once the same desktop has been back for SCREEN_SETTLE_S, the box puts
        itself back where it was.  A drag by hand records whatever desktop it
        is on as the right one, so a monitor unplugged for good strands
        nothing."""
        now = virtual_screen()
        t = time.monotonic()
        if now != self._seen:
            self._seen, self._screens_changed = now, t
        if now != self._screens:
            self._displaced = True
        elif self._displaced and t - self._screens_changed >= SCREEN_SETTLE_S:
            self._displaced = False
            log("the desktop is as it was again; back to %d,%d" % (self.x, self.top))
            self._fit()
        self.root.after(SCREEN_POLL_MS, self._watch_screens)

    def _unsettled(self):
        """Is an outside move now most likely the desktop rearranging itself?"""
        if self._screens is None:
            return False
        return (self._displaced or virtual_screen() != self._screens
                or time.monotonic() - self._screens_changed < SCREEN_SETTLE_S)

    def _wm_window(self):
        """The window the desktop deals with: Tk's WRAPPER, the parent of
        winfo_id(), when the window manager has one; the window itself when it
        does not (--no-taskbar).  Properties meant for other programs -- the
        decoration hint, the look below -- belong on this one, since it is
        what a window list names."""
        if self._wm_id is None:
            self._wm_id = str(self.root.winfo_id())
            try:
                self.root.update_idletasks()
                tree = subprocess.run(["xwininfo", "-tree", "-id", str(self.root.winfo_id())],
                                      capture_output=True, text=True, timeout=5).stdout
                m = re.search(r"Parent window id: (0x[0-9a-fA-F]+)", tree)
                root_m = re.search(r"Root window id: (0x[0-9a-fA-F]+)", tree)
                if m and (root_m is None or m.group(1) != root_m.group(1)):
                    self._wm_id = str(int(m.group(1), 16))
            except (OSError, ValueError, subprocess.SubprocessError, tk.TclError):
                pass
        return self._wm_id

    def _undecorate(self):
        """Ask the window manager for no title bar or border, before the
        window is first mapped: _MOTIF_WM_HINTS flags=2 (decorations given),
        decorations=0, on Tk's WRAPPER -- the parent of winfo_id(), which is
        what the window manager manages.  wm_frame() names the inner window
        until the window has been mapped, so it cannot be used here.

        Windows has no such hint.  There the frame goes with overrideredirect,
        which also takes the window off the taskbar, and the taskbar entry is
        put back by marking Tk's wrapper an "application window" -- while it
        is still withdrawn, since the taskbar decides when a window is
        shown."""
        if sys.platform == "win32":
            try:
                import ctypes
                from ctypes import wintypes
                user32 = ctypes.WinDLL("user32")
                user32.GetParent.restype = wintypes.HWND
                user32.GetParent.argtypes = [wintypes.HWND]
                user32.GetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int]
                user32.SetWindowLongW.argtypes = [wintypes.HWND, ctypes.c_int, wintypes.LONG]
                self.root.overrideredirect(True)
                self.root.update_idletasks()
                wrapper = user32.GetParent(self.root.winfo_id())
                GWL_EXSTYLE, WS_EX_TOOLWINDOW, WS_EX_APPWINDOW = -20, 0x00000080, 0x00040000
                style = user32.GetWindowLongW(wrapper, GWL_EXSTYLE)
                user32.SetWindowLongW(wrapper, GWL_EXSTYLE,
                                      (style & ~WS_EX_TOOLWINDOW) | WS_EX_APPWINDOW)
            except (OSError, AttributeError, tk.TclError) as e:
                log("cannot ask for an undecorated window (it will have a title bar): %s" % e)
            return
        try:
            self.root.update_idletasks()
            wrapper = self._wm_window()
            if wrapper == str(self.root.winfo_id()):
                raise ValueError("no wrapper window for %s" % hex(self.root.winfo_id()))
            subprocess.run(["xprop", "-id", wrapper, "-f", "_MOTIF_WM_HINTS", "32c",
                            "-set", "_MOTIF_WM_HINTS", "2, 0, 0, 0, 0"],
                           check=False, stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=5)
            back = subprocess.run(["xprop", "-id", wrapper, "_MOTIF_WM_HINTS"],
                                  capture_output=True, text=True, timeout=5).stdout
            if "2, 0, 0, 0, 0" not in back:
                raise ValueError("the hint did not stick: %s" % back.strip())
        except (OSError, ValueError, subprocess.SubprocessError, tk.TclError) as e:
            log("cannot ask for an undecorated window (it will have a title bar): %s" % e)

    # -- size and place ---------------------------------------------------
    def _fit(self):
        """Put the box where it belongs, at the size it has been given, and
        wrap the text to that width.  Called when it is first shown, while it
        is dragged or resized in --edit, and when it goes home after the
        desktop has changed -- never for a caption (see THE BOX STAYS PUT)."""
        self.label.configure(wraplength=max(50, self.w - 2 * PAD_X - 8))
        self.h = self.min_h
        self.root.geometry("%dx%d+%d+%d" % (self.w, self.h, self.x, self.top))
        self._asked = (self.w, self.h, self.x, self.top)
        # macOS reports the steps on the way to a new size, and each looked
        # like a resize from outside.  So its own changes are given a moment
        # to settle before a report is believed.
        self._own_until = time.monotonic() + 0.3

    def options(self):
        """The command-line options that make this box again."""
        return "--geometry %dx%d+%d+%d --font-size %d --align %s" % (
            self.w, self.min_h, self.x, self.top,
            int(self.font.cget("size")), self.align)

    def look(self):
        """Everything but the geometry: what the box is to look like.  Kept on
        the window itself (_NSTS_SUBTITLES) so a layout can be saved with the
        look it was arranged with -- see windowLayout.py."""
        return "--font %s --font-size %d --fg %s --bg %s --opacity %s --align %s" % (
            self.font.cget("family"), int(self.font.cget("size")),
            self.args.fg, self.args.bg, self.args.opacity, self.align)

    def _publish_look(self):
        if sys.platform in ("darwin", "win32"):
            # No X11 window to hang it on: a file named for this process,
            # which windowLayout.py reads beside the window's place.
            path = look_file(os.getpid())
            try:
                with open(path, "w") as fh:
                    fh.write(self.look() + "\n")
                if not getattr(self, "_look_cleanup", False):
                    # Removed at exit -- including SIGTERM, which is how
                    # simulatePASS.py stops it and which skips atexit alone.
                    import atexit
                    import signal
                    atexit.register(lambda: os.path.exists(path) and os.remove(path))
                    signal.signal(signal.SIGTERM, lambda *_a: sys.exit(0))
                    self._look_cleanup = True
            except OSError:
                pass
            return
        try:
            subprocess.run(["xprop", "-id", self._wm_window(),
                            "-f", "_NSTS_SUBTITLES", "8u",
                            "-set", "_NSTS_SUBTITLES", self.look()],
                           check=False, stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL, timeout=5)
        except (OSError, subprocess.SubprocessError):
            pass

    def _report(self):
        log("options: " + self.options())
        self._publish_look()

    def _where(self):
        """(x, y) of the window, in the terms geometry() sets it in.

        ON macOS THOSE ARE NOT winfo_rootx/rooty.  The box cannot be
        undecorated there (the _MOTIF_WM_HINTS request is X11's), so it has a
        title bar; geometry() places the FRAME, while winfo_rooty() is the
        inside, a title bar's height lower.  Taken as a move from outside,
        that difference became the box's new top, and the next caption
        placed it from there: the box walked down the screen a title bar at a
        time until the stay-on-screen rule threw it back up."""
        if sys.platform == "darwin":
            m = re.match(r"\d+x\d+([+-]-?\d+)([+-]-?\d+)$", self.root.wm_geometry())
            if m:
                return int(m.group(1)), int(m.group(2))
        return self.root.winfo_rootx(), self.root.winfo_rooty()

    def _sync_place(self):
        """Take the box's place from the window itself: the window manager may
        have put it somewhere other than where it was asked to go."""
        self.root.update_idletasks()
        if self.root.winfo_ismapped():
            self.x, y = self._where()
            self.top = y

    def _drag_start(self, e):
        self._sync_place()
        self._grab = (e.x_root - self.x, e.y_root - self.top)
        self._moved = False
        if self.args.edit:
            self.root.focus_force()
            if sys.platform == "win32":
                self.root.after(100, self._recheck_focus)

    def _drag(self, e):
        self.x = e.x_root - self._grab[0]
        self.top = e.y_root - self._grab[1]
        self._moved = True
        self._fit()

    def _drag_end(self, _e):
        if self._moved or self._resize_from is not None:
            # Put here by hand: this desktop is the right one (_watch_screens).
            self._screens = self._seen = virtual_screen()
            self._displaced = False
        if (self._moved or self._resize_from is not None) and self.args.edit:
            self._report()
        self._moved = False
        self._resize_from = None

    def _resize_start(self, e):
        self._sync_place()
        self._resize_from = (e.x_root, e.y_root, self.w, self.min_h)
        self.root.focus_force()

    def _resize(self, e):
        if self._resize_from is None:
            return
        x0, y0, w0, h0 = self._resize_from
        self.w = max(MIN_W, w0 + (e.x_root - x0))
        self.min_h = max(MIN_H, h0 + (e.y_root - y0))
        self._fit()

    def _configured(self, e):
        if e.widget is not self.root or self._asked is None:
            return
        if sys.platform == "darwin" and time.monotonic() < getattr(self, "_own_until", 0):
            return                    # our own change, still settling (see _fit)
        if sys.platform == "darwin":
            # From the event: macOS delivers the new frame position in it
            # before wm_geometry() -- and so _where() -- has caught up.
            now = (e.width, e.height, e.x, e.y)
        else:
            now = (self.root.winfo_width(), self.root.winfo_height(),
                   self.root.winfo_rootx(), self.root.winfo_rooty())
        if now == self._asked:
            return                    # our own geometry call coming back
        if self._unsettled():
            return                    # Windows moving it off a departed monitor
        self._asked = now
        self.w, self.x = now[0], now[2]
        self.h = self.min_h = now[1]  # a size set from outside is the new size
        self.top = now[3]
        self.label.configure(wraplength=max(50, self.w - 2 * PAD_X - 8))
        self._report() if self.args.edit else None

    def _menu(self, e):
        try:
            self.popup.tk_popup(e.x_root, e.y_root)
        finally:
            self.popup.grab_release()

    # -- the caption --------------------------------------------------------
    def show(self, text):
        text = text.replace("\\n", "\n")
        shown = text if self.args.edit else text.strip()
        align = self.align
        tag = ALIGN_TAG.match(shown)
        if tag:
            align = tag.group(1).lower().replace("centre", "center")
            shown = shown[tag.end():]
        if self.args.edit and self.cursor_wanted and self.focused:
            shown += EDIT_CURSOR
        # The text only: the box keeps its place and size (THE BOX STAYS PUT).
        self.label.configure(text=shown, justify=align, anchor=ANCHORS[align])
        if self.args.hide_when_empty and not self.args.edit:
            if shown:
                self.root.deiconify()
            else:
                self.root.withdraw()

    def _focus(self, focused):
        if focused != self.focused:
            self.focused = focused
            self.show(self.text)
        if focused and sys.platform == "win32" and not self._focus_polling:
            self._focus_polling = True
            self.root.after(FOCUS_POLL_MS, self._poll_focus)

    def _poll_focus(self):
        self._focus_polling = False
        self._recheck_focus()

    def _recheck_focus(self):
        """WINDOWS: THE KEYBOARD AS WINDOWS SEES IT.  Tk on Windows does not
        always deliver the FocusOut when another window takes the keyboard
        (seen with the box started from manager.py), and then the cursor
        stays.  So while the box thinks it has the keyboard, ask Windows."""
        self._focus(self._foreground())

    def _ours(self, user32):
        return user32.GetAncestor(self.root.winfo_id(), 2)        # GA_ROOT

    def _foreground(self):
        try:
            user32 = _user32()
            ours = self._ours(user32)
            return ours is not None and user32.GetForegroundWindow() == ours
        except (OSError, AttributeError, tk.TclError):
            return self.focused

    def _give_keyboard_back(self, before):
        try:
            user32 = _user32()
            ours = self._ours(user32)
            if before is not None and before != ours and user32.GetForegroundWindow() == ours:
                user32.SetForegroundWindow(before)
        except (OSError, AttributeError, tk.TclError):
            pass

    def _key(self, e):
        ctrl = bool(e.state & 0x4)
        k = e.keysym
        if ctrl:
            if k in ("plus", "equal", "KP_Add"):
                self.font.configure(size=int(self.font.cget("size")) + 2)
            elif k in ("minus", "underscore", "KP_Subtract"):
                self.font.configure(size=max(6, int(self.font.cget("size")) - 2))
            elif k.lower() in ("l", "e", "r"):
                self.align = {"l": "left", "e": "center", "r": "right"}[k.lower()]
            elif k.lower() == "p":
                self._report()
                return "break"
            elif k.lower() == "h":
                self.cursor_wanted = not self.cursor_wanted
                self.show(self.text)
                return "break"
            else:
                return None
            self.show(self.text)
            self._report()
            return "break"
        if k in ("Return", "KP_Enter"):
            self.text += "\n"
        elif k == "BackSpace":
            self.text = self.text[:-1]
        elif k == "Escape":
            self.text = ""
        elif e.char and e.char.isprintable():
            self.text += e.char
        else:
            return None
        self.show(self.text)
        return "break"

    # -- the bus ------------------------------------------------------------
    def _listen(self):
        port = subtitle_port()
        try:
            s = receiver(port)
        except OSError as e:
            log("cannot listen on %s:%d: %s" % (D.GROUP, port, e))
            return
        log("listening on %s:%d" % (D.GROUP, port))
        while True:
            try:
                data, _ = s.recvfrom(65536)
            except OSError:
                return
            self.q.put(data.decode("utf-8", errors="replace"))

    def _poll(self):
        try:
            while True:
                text = self.q.get_nowait()
                log("caption: %r" % text if text.strip() else "cleared")
                self.text = text.replace("\\n", "\n")
                self.show(self.text)
        except queue.Empty:
            pass
        self.root.after(50, self._poll)


EPILOG = """\
captions:
  a script line '<seconds> subtitle TEXT' shows TEXT; with no TEXT it clears.
  The two characters \\n in TEXT start a new line.  TEXT may begin with
  <left>, <center> or <right> to align that caption alone.

the box:
  keeps its --geometry place and size whatever the caption; a caption with
  more lines than the height holds is cut off.  Only dragging (--edit) or
  restoring a window layout moves or resizes it.
  right button    Clear / Quit
  Ctrl Q          quit

editing controls (--edit only):
  typing          set the caption
  Enter           new line
  Backspace       delete the last character
  Escape          clear the caption
  drag            move the box
  Ctrl + / Ctrl = font size up 2 points
  Ctrl -          font size down 2 points
  Ctrl L / E / R  align left, centre, right
  Shift-drag      set width (left-right) and height (up-down)
  Ctrl P          print the options that reproduce the box
  Ctrl H          hide or show the cursor; it shows only while the box has
                  the keyboard, so clicking another window also hides it
  after each change of size, place, font size or alignment it prints
  '--geometry WxH+X+Y --font-size N --align A' to paste into a command line.
"""


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Caption box for demonstration videos, driven over the simulation's bus",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=EPILOG)
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range (default 6900, or NSTS_BUS_PORT_BASE); "
                         "captions arrive on base+%d" % SUBTITLE_OFFSET)
    ap.add_argument("--geometry", metavar="WxH+X+Y", default=None,
                    help="size and place (default %dx%d, bottom centre); the box "
                         "keeps them whatever the caption" % (DEFAULT_W, DEFAULT_H))
    ap.add_argument("--font", default="Helvetica", help="font family (default Helvetica)")
    ap.add_argument("--font-size", type=int, default=28, metavar="PT")
    ap.add_argument("--fg", default="#ffffff", help="text colour (default white)")
    ap.add_argument("--bg", default="#000000", help="box colour (default black)")
    ap.add_argument("--opacity", type=float, default=0.85,
                    help="0-1, where the window manager supports it (default 0.85)")
    ap.add_argument("--align", choices=sorted(ANCHORS), default="center",
                    help="horizontal alignment of the caption (default center)")
    ap.add_argument("--edit", action="store_true",
                    help="type into the box to try captions, sizes and placement; "
                         "prints the options that reproduce what you settle on")
    ap.add_argument("--no-taskbar", action="store_true",
                    help="an unmanaged window, as before: never framed by the window "
                         "manager, but not listed in the taskbar either")
    ap.add_argument("--hide-when-empty", action="store_true",
                    help="withdraw the box while there is no caption")
    ap.add_argument("--text", default="", help="caption to show at start")
    args = ap.parse_args(argv)
    if args.port_base is not None:
        D.set_port_base(args.port_base)

    import macdock; macdock.set_app_name("Captions")                  # its Dock name
    before = foreground_window()     # Tk() takes the keyboard on Windows
    root = tk.Tk()
    import windowLayout; windowLayout.claim(root)   # whose window this is
    if args.geometry:
        m = GEOMETRY.match(args.geometry.strip())
        if not m:
            raise SystemExit("subtitles: --geometry is WxH+X+Y, e.g. 1000x120+460+880")
        box = (int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4)))
    else:
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        w = min(DEFAULT_W, sw)
        box = (w, DEFAULT_H, max(0, (sw - w) // 2), max(0, sh - DEFAULT_H - BOTTOM_MARGIN))
    Subtitles(root, args, box, before)
    root.mainloop()


if __name__ == "__main__":
    main()
