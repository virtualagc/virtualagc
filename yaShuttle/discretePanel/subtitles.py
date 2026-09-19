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

THE BOX GROWS TO FIT.  The width stays as given; a caption that wraps to more
lines than the height holds makes the box taller, DOWNWARD, so its top edge
stays put and the extra lines cover nothing above the caption, and a shorter
caption brings it back to the height given (never less).  Only if the box
would run off the bottom of the screen is it moved up, and only by as much as
that needs.

TRYING SIZES: --edit.  The box takes the keyboard, so captions can be typed
straight into it to find a geometry and font size that suit a recording:

    typing          the caption (Enter: new line, Backspace, Escape: clear)
    Ctrl + / Ctrl - font size up or down by 2 points
    Ctrl L / E / R  align left, centre or right
    drag            move the box
    Shift-drag      change its width and its (minimum) height
    Ctrl P          print the options that reproduce the box
    Ctrl H          hide or show the cursor (it shows only while the box
                    has the keyboard anyway, so clicking another window
                    hides it for a recording)

After any change of size, place, font size or alignment it prints the
equivalent options -- '--geometry WxH+X+Y --font-size N --align A' -- to
paste into the command line.  Captions from the bus still arrive meanwhile.

THE WINDOW has no title bar, so it is moved by dragging it with the left
button; the right button offers Clear and Quit, and Ctrl+Q quits.  It stays
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
import socket
import struct
import subprocess
import threading
import tkinter as tk
import tkinter.font as tkfont

import discretes as D

SUBTITLE_OFFSET = 90
DEFAULT_W, DEFAULT_H = 1000, 120
BOTTOM_MARGIN = 80
PAD_X, PAD_Y = 16, 8
MIN_W, MIN_H = 200, 40
EDIT_CURSOR = "▌"          # the block shown after typed text in --edit
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
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
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


class Subtitles(object):
    def __init__(self, root, args, box):
        """box: (width, minimum height, x, y) -- y the top at that height."""
        self.root = root
        self.args = args
        # The box is kept here rather than read back from the window, which
        # has no size of its own until it is mapped: width, least height, the
        # left edge, and the TOP edge, which stays put as the box grows.
        self.w, self.min_h, self.x, self.top = box
        self.shift = 0                        # moved up this far to stay on screen
        self.h = None
        self._wm_id = None            # the window the desktop deals with
        self._asked = None            # the geometry this program last set
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
        root.attributes("-topmost", True)
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
        # events, so binding both ran every handler twice.
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
        self.show(self.text)
        if not args.no_taskbar and (args.edit or not (args.hide_when_empty
                                                      and not self.text.strip())):
            root.deiconify()
        if args.edit:
            root.after(200, root.focus_force)
            log("--edit: type a caption; Ctrl +/- font, Ctrl L/E/R align, "
                "Shift-drag size, Ctrl P options, Ctrl H cursor")
            self._report()
        root.after(300, self._publish_look)
        threading.Thread(target=self._listen, daemon=True).start()
        root.after(50, self._poll)

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
        until the window has been mapped, so it cannot be used here."""
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
        """Wrap to the width, then make the box as tall as the text needs, but
        no shorter than the height given, growing downward from its top edge
        -- moved up only if it would otherwise run off the bottom of the
        screen."""
        self.label.configure(wraplength=max(50, self.w - 2 * PAD_X - 8))
        self.root.update_idletasks()
        self.h = max(self.min_h, self.label.winfo_reqheight())
        over = self.top + self.h - self.root.winfo_screenheight()
        self.shift = max(0, min(over, self.top))
        self.root.geometry("%dx%d+%d+%d" % (self.w, self.h, self.x, self.top - self.shift))
        self._asked = (self.w, self.h, self.x, self.top - self.shift)

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

    def _sync_place(self):
        """Take the box's place from the window itself: the window manager may
        have put it somewhere other than where it was asked to go."""
        self.root.update_idletasks()
        if self.root.winfo_ismapped():
            self.x = self.root.winfo_rootx()
            self.top = self.root.winfo_rooty() + self.shift

    def _drag_start(self, e):
        self._sync_place()
        self._grab = (e.x_root - self.x, e.y_root - self.top)
        self._moved = False
        if self.args.edit:
            self.root.focus_force()

    def _drag(self, e):
        self.x = e.x_root - self._grab[0]
        self.top = e.y_root - self._grab[1]
        self._moved = True
        self._fit()

    def _drag_end(self, _e):
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
        now = (self.root.winfo_width(), self.root.winfo_height(),
               self.root.winfo_rootx(), self.root.winfo_rooty())
        if now == self._asked:
            return                    # our own geometry call coming back
        self._asked = now
        self.w, self.x = now[0], now[2]
        self.h = self.min_h = now[1]  # a size set from outside is the new least
        self.top, self.shift = now[3], 0
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
        self.label.configure(text=shown, justify=align, anchor=ANCHORS[align])
        self._fit()
        if self.args.hide_when_empty and not self.args.edit:
            if shown:
                self.root.deiconify()
                self.root.attributes("-topmost", True)
            else:
                self.root.withdraw()

    def _focus(self, focused):
        if focused != self.focused:
            self.focused = focused
            self.show(self.text)

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
  grows downward, top edge fixed, when a caption wraps past its height, and
  returns to the --geometry height (never less) for a shorter one.  It moves
  up only as far as it must to stay on the screen.
  drag            move it
  right button    Clear / Quit
  Ctrl Q          quit

editing controls (--edit only):
  typing          set the caption
  Enter           new line
  Backspace       delete the last character
  Escape          clear the caption
  Ctrl + / Ctrl = font size up 2 points
  Ctrl -          font size down 2 points
  Ctrl L / E / R  align left, centre, right
  Shift-drag      set width (left-right) and minimum height (up-down)
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
                    help="width, least height and place (default %dx%d, bottom centre); "
                         "the box grows taller, downward, for a caption that needs it"
                         % (DEFAULT_W, DEFAULT_H))
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
    Subtitles(root, args, box)
    root.mainloop()


if __name__ == "__main__":
    main()
