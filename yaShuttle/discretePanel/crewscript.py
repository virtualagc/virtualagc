#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""The crew script: ONE file that says everything the crew does in a
scripted run -- panel switches, keystrokes, captions -- and when.

panelO6.py plays it (--script FILE; simulatePASS.py --script passes it on).
One player means one clock and one reading of each wait, so the switches and
the keystrokes stay in step by construction.

THE LANGUAGE is described by HELP below, which is what the programs that take
a crew script print in their --help, and what this module prints when run:

    python3 crewscript.py --help           the commands
    python3 crewscript.py FILE ...         check scripts without running them
"""

import re
import socket
import struct
import time

import discretes as D

KEYBOARD_OFFSET = 30            # keyboard n's bus: port base + 30 + n
IDP_BUS_OFFSET = 40             # IDP n's bus: port base + 40 + n
SUBTITLE_OFFSET = 90            # subtitles.py: port base + 90
MAX_SCRIPT_SECONDS = 36000
WAIT_TIMEOUT_S = 600
KEY_GAP_S = 0.35
WAIT_POLL_MS = 100

# DPS keyboard scan codes (stsKeyboard.py's SCAN, from MEDS2.py's KYBD.DEUKey).
SCAN = {
    "FAULT_SUMM": 0xFFE1, "SYS_SUMM": 0xFFE9, "MSG_RESET": 0xFFF1, "ACK": 0xFFF9,
    "GPC/CRT": 0xFFC1, "A": 0xFFC9, "B": 0xFFD1, "C": 0xFFD9,
    "I/O_RESET": 0xFF3A, "D": 0xFF7A, "E": 0xFFBA, "F": 0xFFFA,
    "ITEM": 0xFE3A, "1": 0xFE7A, "2": 0xFEFB, "3": 0xFEFA,
    "EXEC": 0xF9FB, "4": 0xFBFB, "5": 0xFDFB, "6": 0xFFFB,
    "OPS": 0xF1FB, "7": 0xF3FB, "8": 0xF5FB, "9": 0xF7FB,
    "SPEC": 0xCFFC, "-": 0xDFFC, "0": 0xEFFC, "+": 0xFFFC,
    "RESUME": 0x8FFC, "CLEAR": 0x9FFC, ".": 0xAFFC, "PRO": 0xBFFC,
}
# MDU -> IDP messages on an _IDPn bus (MEDS2.py's MDUMsg): IDP POWER and IDP
# LOAD, which panelO6.py's C2 and O6 switches send and follow.
IDP_MSG = {"DEU_LOAD": (0x0002,), "IDP_POWER_ON": (0x0003, 1), "IDP_POWER_OFF": (0x0003, 0)}

PANEL_VERBS = ("gpc", "mode", "ipl", "source", "crt", "bfsengage", "gpcid", "bit",
               "idppower", "majfunc", "kybdsel", "idpload")
TALKBACK_STATES = ("RUN", "IPL", "BP")

# The key names a script may use, as the keyboard has them, then the IDP ones.
_KEY_NAMES = " ".join(["ITEM", "EXEC", "OPS", "PRO", "SPEC", "RESUME", "CLEAR",
                       "+", "-", ".", "0-9", "A-F"]
                      + [k for k in SCAN if len(k) > 1 and k not in
                         ("ITEM", "EXEC", "OPS", "PRO", "SPEC", "RESUME", "CLEAR")]
                      + list(IDP_MSG) + ["IDP2_" + k[4:] if k.startswith("IDP_") else k + "2"
                                         for k in IDP_MSG])


def _wrap(text, indent):
    import textwrap
    return textwrap.fill(text, 76, initial_indent=indent, subsequent_indent=indent)


# For --help screens: RawDescriptionHelpFormatter keeps the layout.
HELP = """\
  One command per line; '#' starts a comment (so a subtitle cannot contain
  one); blank lines are ignored.  Every line is checked when the file is
  read, so a mistake is reported before anything happens.

  <seconds> <command>   a timed step.  SECONDS (decimals allowed) from the
                        start, or from when the last wait line was met.
                        Lines run in file order; a time may not be earlier
                        than the line before it since the last wait.

  waits (no time in front):
    wait gpc N mode-tb RUN|IPL|BP [timeout S]
                        hold until GPC N's MODE talkback on panel O6 shows
                        that state: RUN when a load is complete, IPL while a
                        bootstrap is in, BP (barberpole) otherwise.  A
                        timeout (default %(timeout)d s) stops the script.
    wait user           hold until someone clicks in the panel O6 window (the
                        cursor changes; the click moves no control).
                        --wait-user puts one first.

  keyboard and captions:
    keys [KB1|KB2|KB3] KEY ...
                        type on a DPS keyboard, %(gap)s s apart; KB1 (left)
                        unless a KBn token says otherwise, and one part way
                        along switches the rest.  The next line starts when
                        the typing is done.  Keys:
%(keys)s
    subtitle [TEXT]     show TEXT in the caption box (subtitles.py); no TEXT
                        clears it.  The two characters \\n start a new line;
                        a leading <left>, <center> or <right> aligns that
                        caption.

  panel controls (on the GPC column chosen by 'gpc N', at first the primary):
    gpc N               drive GPC N's column from here on (1-5)
    mode HALT|STANDBY|RUN
                        that column's MODE switch (STBY also accepted)
    ipl                 its IPL pushbutton, held 0.25 s
    source MM1|MM2|OFF  IPL SOURCE
    crt 0|1|2|3         BFC CRT: 0 is DISPLAY OFF, else DISPLAY ON and
                        SELECT 1+2 / 2+3 / 3+1
    bfsengage on|off    on: CDR ENGAGE pressed and released; off: BFC
                        DISENGAGE to RIGHT and back
    gpcid N             make GPC N the primary column
    bit A|B N on|off    one discrete bit: A12 I/O TERM A, A13 OUTPUT
                        TERMINATE/NORMAL, B3-5 bfsengage, B6-7 crt; any other
                        is sent once, raw
    idppower N on|off   IDP/CRT N POWER (1-3 on C2, 4 on R11)
    majfunc N GNC|SM|PL IDP/CRT N MAJ FUNC
    kybdsel left 1|3    LEFT IDP/CRT SEL
    kybdsel right 2|3   RIGHT IDP/CRT SEL
    idpload N           O6 IDP N LOAD (1-4), held 0.25 s

  example (examples/4gpc-startup.script has a full one):
    0     gpc 1
    0     mode HALT
    0.2   source MM1
    0.5   ipl
    3     mode STANDBY
    70    keys ITEM 1 EXEC
    wait gpc 1 mode-tb RUN timeout 300
    1     subtitle <left> GPC 1 loaded\\nnow to RUN
    3     mode RUN

  To check a script without running anything:  python3 crewscript.py FILE
""" % {"timeout": WAIT_TIMEOUT_S, "gap": KEY_GAP_S,
       "keys": _wrap(_KEY_NAMES, " " * 24)}


class ScriptError(Exception):
    pass


def key_codes(words):
    """KEY words -> [(bus, unit, words, name)]: ('kb', n, (scan,)) or ('idp', n, msg)."""
    out, kbd = [], 1
    for word in words:
        k = word.upper()
        if k in ("KB1", "KB2", "KB3"):
            kbd = int(k[2])
            continue
        idp = 1
        if k.startswith("IDP2_"):
            idp, k = 2, "IDP_" + k[5:]
        elif k.endswith("2") and k[:-1] in IDP_MSG:
            idp, k = 2, k[:-1]
        if k in IDP_MSG:
            out.append(("idp", idp, IDP_MSG[k], word))
        elif k in SCAN:
            out.append(("kb", kbd, (SCAN[k],), word))
        else:
            raise ScriptError("unknown key %r" % word)
    return out


def parse_wait(arg):
    """'gpc N mode-tb STATE [timeout S]' -> (N, STATE, seconds)."""
    w = arg.split()
    bad = ScriptError("expected 'wait gpc N mode-tb RUN|IPL|BP [timeout S]', got %r" % arg)
    if len(w) not in (4, 6) or w[0].lower() != "gpc" or w[2].lower() != "mode-tb":
        raise bad
    try:
        gpc = int(w[1])
        timeout = WAIT_TIMEOUT_S
        if len(w) == 6:
            if w[4].lower() != "timeout":
                raise ValueError
            timeout = float(w[5])
    except ValueError:
        raise bad
    state = {"BARBERPOLE": "BP"}.get(w[3].upper(), w[3].upper())
    if not 1 <= gpc <= 5 or state not in TALKBACK_STATES:
        raise bad
    return gpc, state, timeout


def parse(text):
    """The whole script -> entries in running order, each a dict with 'line':
    {'kind': 'wait', 'gpc', 'state', 'timeout', 'text'} or
    {'kind': 'step', 'ms', 'verb', 'arg', 'keys' (for keys lines), 'text'}.
    Raises ScriptError naming the line."""
    entries, last_ms = [], 0
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        try:
            first, _, rest = line.partition(" ")
            rest = rest.strip()
            if first.lower() == "wait" and rest.lower() == "user":
                entries.append({"kind": "wait_user", "text": line, "line": n})
                last_ms = 0
                continue
            if first.lower() == "wait":
                gpc, state, timeout = parse_wait(rest)
                entries.append({"kind": "wait", "gpc": gpc, "state": state,
                                "timeout": timeout, "text": line, "line": n})
                last_ms = 0
                continue
            try:
                seconds = float(first)
            except ValueError:
                raise ScriptError("expected '<seconds> <command>' or 'wait ...', got %r" % line)
            if seconds != seconds or seconds < 0 or seconds == float("inf"):
                raise ScriptError("bad time %r" % first)
            if seconds > MAX_SCRIPT_SECONDS:
                raise ScriptError("%s seconds is over %d -- script times are SECONDS, "
                                  "not milliseconds (divide by 1000)"
                                  % (first, MAX_SCRIPT_SECONDS))
            ms = int(round(seconds * 1000))
            if ms < last_ms:
                raise ScriptError("time %s is earlier than the line before it -- lines run "
                                  "in file order, so times may not go backwards between waits"
                                  % first)
            last_ms = ms
            verb, _, arg = rest.partition(" ")
            verb, arg = verb.lower(), arg.strip()
            entry = {"kind": "step", "ms": ms, "verb": verb, "arg": arg,
                     "text": line, "line": n}
            if verb == "keys":
                if not arg:
                    raise ScriptError("keys needs at least one key")
                entry["keys"] = key_codes(arg.split())
            elif verb == "subtitle":
                pass
            elif verb not in PANEL_VERBS:
                raise ScriptError("unknown command %r" % verb)
            entries.append(entry)
        except ScriptError as e:
            raise ScriptError("script line %d: %s" % (n, e))
    return entries


def has_wait_user(text):
    """Does this script wait for a person?  Then it needs a window to click."""
    for raw in text.splitlines():
        w = raw.split("#", 1)[0].split()
        if len(w) == 2 and w[0].lower() == "wait" and w[1].lower() == "user":
            return True
    return False


def has_subtitles(text):
    """Does this script caption?  Cheap enough for a launcher to ask."""
    for raw in text.splitlines():
        w = raw.split("#", 1)[0].split()
        if len(w) >= 2 and w[0][:1].isdigit() and w[1].lower() == "subtitle":
            return True
    return False


class Bus(object):
    """Sends what a script says onto the simulation's buses (port base from
    discretes.py, so set_port_base() first)."""

    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF,
                             socket.inet_aton(D.IFACE))
        self.sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)

    def send_key(self, key):
        bus, unit, words, _name = key
        offset = KEYBOARD_OFFSET if bus == "kb" else IDP_BUS_OFFSET
        self.sock.sendto(struct.pack(">%dH" % len(words), *words),
                         (D.GROUP, D.PORT_BASE + offset + unit))

    def send_subtitle(self, text):
        self.sock.sendto(text.encode("utf-8"), (D.GROUP, D.PORT_BASE + SUBTITLE_OFFSET))


class Player(object):
    """Runs parsed entries on the host's event loop.

    after(ms, fn)       schedule fn (Tk's root.after)
    panel(verb, arg)    carry out a panel command
    talkback(gpc)       'RUN', 'IPL' or 'BP' for GPC N now
    log(text)           report what happened
    wait_user(done)     optional: let a person say go, calling done() when
                        they do; without it a 'wait user' stops the script
    """

    def __init__(self, entries, after, panel, talkback, log, bus=None, wait_user=None):
        self.entries, self.after, self.panel = entries, after, panel
        self.talkback, self.log = talkback, log
        self.wait_user = wait_user
        self.bus = bus or Bus()
        self.origin = None
        self.stopped = False

    def start(self):
        self.origin = time.monotonic()
        self.after(0, lambda: self._run(0))

    def _run(self, k):
        while k < len(self.entries) and not self.stopped:
            e = self.entries[k]
            if e["kind"] == "wait_user":
                if self.wait_user is None:
                    self.log("%s: nothing to click -- script stopped" % e["text"])
                    self.stopped = True
                    return
                self.log("%s: click in the panel window to continue" % e["text"])
                begun = time.monotonic()

                def resumed(k=k, begun=begun):
                    if self.stopped:
                        return
                    self.log("wait user met after %.1f s" % (time.monotonic() - begun))
                    self.origin = time.monotonic()
                    self._run(k + 1)
                self.wait_user(resumed)
                return
            if e["kind"] == "wait":
                self.log(e["text"])
                self._poll(k, e, time.monotonic())
                return
            due = self.origin + e["ms"] / 1000.0 - time.monotonic()
            if due > 0:
                self.after(int(due * 1000) + 1, lambda k=k: self._run(k))
                return
            if e["verb"] == "keys":
                self.log(e["text"])
                self._type(k, e["keys"], 0)
                return
            self.log(e["text"])
            if e["verb"] == "subtitle":
                try:
                    self.bus.send_subtitle(e["arg"])
                except OSError as err:
                    self.log("cannot send a subtitle: %s" % err)
            else:
                self.panel(e["verb"], e["arg"])
            k += 1
        if k >= len(self.entries) and not self.stopped:
            self.log("script complete")

    def _type(self, k, keys, i):
        if self.stopped:
            return
        if i < len(keys):
            try:
                self.bus.send_key(keys[i])
            except OSError as err:
                self.log("cannot send key %s: %s" % (keys[i][3], err))
            self.after(int(KEY_GAP_S * 1000), lambda: self._type(k, keys, i + 1))
        else:
            self._run(k + 1)

    def _poll(self, k, e, begun):
        if self.stopped:
            return
        waited = time.monotonic() - begun
        if self.talkback(e["gpc"]) == e["state"]:
            self.log("wait met after %.1f s: %s" % (waited, e["text"]))
            self.origin = time.monotonic()
            self._run(k + 1)
        elif waited > e["timeout"]:
            self.log("WAIT TIMED OUT after %.0f s: %s -- script stopped"
                     % (e["timeout"], e["text"]))
            self.stopped = True
        else:
            self.after(WAIT_POLL_MS, lambda: self._poll(k, e, begun))


def main(argv=None):
    import argparse
    import sys
    ap = argparse.ArgumentParser(
        description="Check crew scripts -- the files panelO6.py and simulatePASS.py\n"
                    "take with --script -- without running them.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="crew script commands:\n" + HELP)
    ap.add_argument("files", nargs="*", metavar="FILE", help="script to check")
    args = ap.parse_args(argv)
    if not args.files:
        ap.print_help()
        return 0
    bad = 0
    for name in args.files:
        try:
            with open(name) as f:
                text = f.read()
            entries = parse(text)
        except (OSError, ScriptError) as e:
            print("%s: %s" % (name, e))
            bad += 1
            continue
        waits = sum(1 for e in entries if e["kind"] != "step")
        print("%s: ok, %d steps and %d waits" % (name, len(entries) - waits, waits))
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
