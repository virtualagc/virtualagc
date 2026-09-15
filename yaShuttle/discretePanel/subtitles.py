#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""A caption box for demonstration videos: a borderless window that shows
whatever text arrives on the simulation's bus, and nothing else.

    python3 subtitles.py                      # port base 6900, bottom centre
    python3 subtitles.py --port-base 27000 --font-size 32
    python3 subtitles.py --geometry 1200x140+360+900
    python3 subtitles.py --align left          # left, center (default) or right

Scripts drive it: a simulatePASS.py --keys line '<seconds> SUBTITLE text ...'
or a panelO6.py --script line '<ms> subtitle text ...' replaces the caption,
and the same command with no text clears it.  simulatePASS.py starts this
program by itself when either script contains a subtitle line.

THE BUS.  One UDP datagram per caption, UTF-8, on the discrete bus's multicast
group at port base + 90 (SUBTITLE_OFFSET).  An empty or all-blank datagram
clears the box; the two characters backslash-n in the text start a new line.
A caption may begin with <left>, <center> (or <centre>) or <right> to align
that caption alone; one without uses --align.
Anything can send one:

    python3 -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); \\
      s.sendto(b'OPS 2 transition', ('239.255.1.1', 6990))"

THE WINDOW has no title bar, so it is moved by dragging it with the left
button; the right button offers Clear and Quit, and Ctrl+Q quits.  It stays
above the other windows so a recording always shows it.  It is an ordinary
window the desktop manages -- listed in the taskbar as "Subtitles" -- that
asks not to be decorated (_MOTIF_WM_HINTS); --no-taskbar makes it an
unmanaged one instead, as it first was, which no window manager can frame
but which the taskbar does not list either.
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
# --align: how the lines sit against each other (justify) and where the text
# sits in the box (anchor).
ANCHORS = {"left": "w", "center": "center", "right": "e"}
# A caption's own alignment, at its very start: "<left> Loading PASS".
ALIGN_TAG = re.compile(r"<(left|center|centre|right)>\s*", re.IGNORECASE)


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
    def __init__(self, root, args):
        self.root = root
        self.args = args
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
        font = tkfont.Font(family=args.font, size=args.font_size, weight="bold")
        self.label = tk.Label(root, text="", fg=args.fg, bg=args.bg, font=font,
                              justify=args.align, anchor=ANCHORS[args.align],
                              padx=16, pady=8)
        self.label.pack(fill="both", expand=True)
        root.bind("<Configure>", self._rewrap)
        for w in (root, self.label):
            w.bind("<ButtonPress-1>", self._drag_start)
            w.bind("<B1-Motion>", self._drag)
            w.bind("<ButtonPress-3>", self._menu)
        root.bind_all("<Control-q>", lambda _e: root.quit())
        self.popup = tk.Menu(root, tearoff=0)
        self.popup.add_command(label="Clear", command=lambda: self.show(""))
        self.popup.add_command(label="Quit", command=root.quit)
        self.q = queue.Queue()
        self._grab = (0, 0)
        if not args.no_taskbar:
            self._undecorate()               # before anything can map the window
        self.show(args.text or "")
        if not args.no_taskbar and not (args.hide_when_empty and not (args.text or "").strip()):
            root.deiconify()
        threading.Thread(target=self._listen, daemon=True).start()
        root.after(50, self._poll)

    def _undecorate(self):
        """Ask the window manager for no title bar or border, before the
        window is first mapped: _MOTIF_WM_HINTS flags=2 (decorations given),
        decorations=0, on Tk's WRAPPER -- the parent of winfo_id(), which is
        what the window manager manages.  wm_frame() names the inner window
        until the window has been mapped, so it cannot be used here."""
        try:
            self.root.update_idletasks()
            tree = subprocess.run(["xwininfo", "-tree", "-id", str(self.root.winfo_id())],
                                  capture_output=True, text=True, timeout=5).stdout
            m = re.search(r"Parent window id: (0x[0-9a-fA-F]+)", tree)
            if not m:
                raise ValueError("no parent window for %s" % hex(self.root.winfo_id()))
            wrapper = str(int(m.group(1), 16))
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

    def _rewrap(self, _event=None):
        self.label.configure(wraplength=max(50, self.root.winfo_width() - 40))

    def _drag_start(self, e):
        self._grab = (e.x_root - self.root.winfo_x(), e.y_root - self.root.winfo_y())

    def _drag(self, e):
        self.root.geometry("+%d+%d" % (e.x_root - self._grab[0], e.y_root - self._grab[1]))

    def _menu(self, e):
        try:
            self.popup.tk_popup(e.x_root, e.y_root)
        finally:
            self.popup.grab_release()

    def show(self, text):
        text = text.replace("\\n", "\n").strip()
        align = self.args.align
        tag = ALIGN_TAG.match(text)
        if tag:
            align = tag.group(1).lower().replace("centre", "center")
            text = text[tag.end():]
        self.label.configure(text=text, justify=align, anchor=ANCHORS[align])
        if self.args.hide_when_empty:
            if text:
                self.root.deiconify()
                self.root.attributes("-topmost", True)
            else:
                self.root.withdraw()

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
                self.show(text)
        except queue.Empty:
            pass
        self.root.after(50, self._poll)


def main(argv=None):
    ap = argparse.ArgumentParser(description="Caption box for demonstration videos, "
                                             "driven over the simulation's bus")
    ap.add_argument("--port-base", type=int, metavar="N", default=None,
                    help="base of the UDP port range (default 6900, or NSTS_BUS_PORT_BASE); "
                         "captions arrive on base+%d" % SUBTITLE_OFFSET)
    ap.add_argument("--geometry", metavar="WxH+X+Y", default=None,
                    help="window size and place (default %dx%d, bottom centre)"
                         % (DEFAULT_W, DEFAULT_H))
    ap.add_argument("--font", default="Helvetica", help="font family (default Helvetica)")
    ap.add_argument("--font-size", type=int, default=28, metavar="PT")
    ap.add_argument("--fg", default="#ffffff", help="text colour (default white)")
    ap.add_argument("--bg", default="#000000", help="box colour (default black)")
    ap.add_argument("--opacity", type=float, default=0.85,
                    help="0-1, where the window manager supports it (default 0.85)")
    ap.add_argument("--align", choices=sorted(ANCHORS), default="center",
                    help="horizontal alignment of the caption (default center)")
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
    if args.geometry:
        root.geometry(args.geometry)
    else:
        sw, sh = root.winfo_screenwidth(), root.winfo_screenheight()
        w = min(DEFAULT_W, sw)
        root.geometry("%dx%d+%d+%d" % (w, DEFAULT_H, max(0, (sw - w) // 2),
                                       max(0, sh - DEFAULT_H - BOTTOM_MARGIN)))
    Subtitles(root, args)
    root.mainloop()


if __name__ == "__main__":
    main()
