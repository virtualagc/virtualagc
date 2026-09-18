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

import os
import re
import shlex
import socket
import struct
import threading
import time

import discretes as D

KEYBOARD_OFFSET = 30            # keyboard n's bus: port base + 30 + n
IDP_BUS_OFFSET = 40             # IDP n's bus: port base + 40 + n
SUBTITLE_OFFSET = 90            # subtitles.py: port base + 90
SCREEN_OFFSET = 91              # MEDS2.py's screen announcements: port base + 91
CONTROL_OFFSET = 92             # panelO6.py's script control: port base + 92
SESSION_OFFSET = 93             # simulatePASS.py's own control: port base + 93
# A settled ScreenWatch has heard at least one round of MEDS2.py's
# re-announcements (every 1 s), so "nothing heard" means a display is silent.
SCREEN_SETTLE_S = 2.5
SCREEN_CLOCK = re.compile(r"(\d+/)?\d\d:\d\d:\d\d")
MAX_SCRIPT_SECONDS = 36000
MAX_SCRIPT_DEPTH = 8            # a script calling a script calling a script...
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

# Panel commands and the arguments each takes, checked when a script is read
# (panelO6.py carries them out).  Case does not matter.
_ON_OFF = r"(on|off)"
PANEL_ARGS = {
    "gpc": r"[1-5]",
    "power": _ON_OFF,
    "output": r"(backup|normal|terminate)",
    "ipl": r"",
    "mode": r"(halt|standby|stby|run)",
    "source": r"(mm1|mm2|off)",
    "display": _ON_OFF,
    "select": r"(1\+2|2\+3|3\+1)",
    "crt": r"[0-3]",
    "disengage": r"(left|right)",
    "rhcengage": r"(cdr|plt)",
    "bfsengage": _ON_OFF,
    "idppower": r"[1-4]\s+" + _ON_OFF,
    "majfunc": r"[1-4]\s+(gnc|sm|pl)",
    "kybdsel": r"(left\s+[13]|right\s+[23])",
    "idpload": r"[1-4]",
    "gpcid": r"[1-5]",
    "bit": r"[ab]\s+\d+\s+" + _ON_OFF,
}
PANEL_USAGE = {
    "gpc": "gpc 1-5", "power": "power on|off", "output": "output backup|normal|terminate",
    "ipl": "ipl (no argument)", "mode": "mode halt|standby|run", "source": "source mm1|mm2|off",
    "display": "display on|off", "select": "select 1+2|2+3|3+1", "crt": "crt 0-3",
    "disengage": "disengage left|right", "rhcengage": "rhcengage cdr|plt",
    "bfsengage": "bfsengage on|off", "idppower": "idppower 1-4 on|off",
    "majfunc": "majfunc 1-4 gnc|sm|pl", "kybdsel": "kybdsel left 1|3, or kybdsel right 2|3",
    "idpload": "idpload 1-4", "gpcid": "gpcid 1-5", "bit": "bit a|b N on|off",
}
PANEL_VERBS = tuple(PANEL_ARGS)
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
  +<seconds> <command>  a timed step that many seconds after the line before
                        was due (or after the start or the last wait, if no
                        line came since), as if the sum had been written.  A
                        line added among +N lines needs no renumbering of
                        the lines after it.  The two forms mix freely.

  waits (no time in front).  [timeout S] is the word timeout and a number of
  seconds, e.g. 'timeout 300'; without it a wait gives up after %(timeout)d s:
    wait gpc N mode-tb RUN|IPL|BP [timeout S]
                        hold until GPC N's MODE talkback on panel O6 shows
                        that state: RUN when a load is complete, IPL while a
                        bootstrap is in, BP (barberpole) otherwise.  A
                        timeout (default %(timeout)d s) stops the script.
    wait user           hold until someone clicks in the panel O6 window (the
                        cursor changes; the click moves no control).
                        --wait-user puts one first.
    wait crt N title TEXT [timeout S]
                        hold until TEXT appears anywhere in the top two lines
                        of CRT N's display (1-4), spaces squeezed and case
                        ignored; quotes around TEXT are optional.
    wait crt N new-screen [timeout S]
                        hold until CRT N shows a different page from the one
                        on show when the wait began: its top two lines change,
                        clocks aside.  A page appearing on a blank CRT counts.
                        Both need MEDS2.py running for that CRT.

  keyboard and captions:
    keys [KB1|KB2|KB3] KEY ...
                        type on a DPS keyboard, %(gap)s s apart; KB1 (left)
                        unless a KBn token says otherwise, and one part way
                        along switches the rest.  The next line starts when
                        the typing is done.  Keys:
%(keys)s
    script FILE [NAME=VALUE ...]
                        play another crew script here, then carry on with
                        this one: FILE's own times start when it starts, and
                        this script's remaining times count from when it
                        finishes.  A relative FILE is relative to the script
                        that names it.  The whole tree is read and checked
                        when the first script is read, and a script that
                        calls itself is refused.
                        Each NAME=VALUE fills in $NAME (or ${NAME}) wherever
                        it appears in FILE, so a procedure that differs only
                        in which GPC it is done to can be written once and
                        played for each in turn:
                            script ipl-one-gpc.script gpc=1 sel=1+2
                            script ipl-one-gpc.script gpc=2 sel=2+3
                        and inside ipl-one-gpc.script:
                            +0  gpc $gpc
                            +2  select $sel
                        A $NAME nobody supplies is an error, and so is a value
                        the script never uses -- both are caught when the
                        script is read.  FILE sees only the values it was
                        given; to hand one on to a script FILE itself plays,
                        name it again: script inner.script gpc=$gpc.  Write $$
                        for a literal $, and quote a VALUE that has a space in
                        it.
    subtitle [TEXT]     show TEXT in the caption box (subtitles.py); no TEXT
                        clears it.  The two characters \\n start a new line;
                        a leading <left>, <center> or <right> aligns that
                        caption.

  panel controls, by panel and legend.  The GPC controls act on the column
  chosen by 'gpc N' (at first the primary); case does not matter:
    gpc N               the GPC column the controls below act on (1-5)
   O6, per GPC:
    power on|off        GPC POWER
    output backup|normal|terminate
                        GPC OUTPUT
    ipl                 INITIAL PROGRAM LOAD pushbutton, held 0.25 s
    mode halt|standby|run
                        GPC MODE (stby also accepted)
   O6, shared:
    source mm1|mm2|off  IPL SOURCE
    idpload N           IDP LOAD pushbutton N (1-4), held 0.25 s
   C3, BFC CRT:
    display on|off      DISPLAY
    select 1+2|2+3|3+1  SELECT
    crt 0|1|2|3         both at once: 0 is DISPLAY OFF, else DISPLAY ON and
                        SELECT 1+2 / 2+3 / 3+1
   F6 and the RHCs:
    disengage left|right
                        BFC DISENGAGE (RIGHT disengages)
    rhcengage cdr|plt   that RHC's BFC ENGAGE pushbutton, held 0.25 s
    bfsengage on|off    shortcut: on presses CDR ENGAGE; off moves DISENGAGE
                        to RIGHT and back
   C2 and R11, IDP/CRT N (1-3 on C2, 4 on R11):
    idppower N on|off   IDP/CRT POWER
    majfunc N gnc|sm|pl IDP/CRT MAJ FUNC
    kybdsel left 1|3    LEFT IDP/CRT SEL
    kybdsel right 2|3   RIGHT IDP/CRT SEL
   not a control:
    gpcid N             make GPC N the primary column
    bit a|b N on|off    one discrete bit: A12 I/O TERM A, A13 OUTPUT
                        TERMINATE/NORMAL, B3-5 bfsengage, B6-7 crt; any other
                        is sent once, raw

  example (examples/4gpc-startup.script has a full one):
    0     gpc 1
    +0    mode HALT
    +0.2  source MM1
    +0.3  ipl
    +2.5  mode STANDBY
    +67   keys ITEM 1 EXEC
    wait gpc 1 mode-tb RUN timeout 300
    +1    subtitle <left> GPC 1 loaded\\nnow to RUN
    +2    mode RUN

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
    """The words after 'wait' -> an entry dict (without 'text' and 'line'):
    'gpc N mode-tb STATE [timeout S]'   {'kind': 'wait', 'gpc', 'state', 'timeout'}
    'crt N title TEXT [timeout S]'      {'kind': 'wait_screen', 'mdu', 'title', 'timeout'}
    'crt N new-screen [timeout S]'      the same with title None."""
    w = arg.split()
    timeout = WAIT_TIMEOUT_S
    if len(w) >= 2 and w[-2].lower() == "timeout":
        try:
            timeout = float(w[-1])
        except ValueError:
            raise ScriptError("expected 'timeout S' in seconds, got %r" % " ".join(w[-2:]))
        w = w[:-2]
    elif w and re.fullmatch(r"[0-9]+(\.[0-9]*)?", w[-1]) and len(w) >= 3 \
            and w[-2].lower() in ("mode-tb", "new-screen", "run", "ipl", "bp", "barberpole"):
        raise ScriptError("a timeout is written with the word timeout: '... timeout %s', "
                          "got %r" % (w[-1], arg))
    if w and w[0].lower() == "crt":
        bad = ScriptError("expected 'wait crt N title TEXT [timeout S]' or "
                          "'wait crt N new-screen [timeout S]', got %r" % arg)
        if len(w) < 3 or w[1] not in ("1", "2", "3", "4"):
            raise bad
        mdu = "crt" + w[1]
        if w[2].lower() == "new-screen" and len(w) == 3:
            return {"kind": "wait_screen", "mdu": mdu, "title": None, "timeout": timeout}
        if w[2].lower() == "title" and len(w) > 3:
            text = " ".join(w[3:])
            if len(text) >= 2 and text[0] == text[-1] and text[0] in "\"'":
                text = text[1:-1]
            text = " ".join(text.split())
            if not text:
                raise bad
            return {"kind": "wait_screen", "mdu": mdu, "title": text, "timeout": timeout}
        raise bad
    bad = ScriptError("expected 'wait gpc N mode-tb RUN|IPL|BP [timeout S]', "
                      "'wait crt N title TEXT' or 'wait crt N new-screen', got %r" % arg)
    if len(w) != 4 or w[0].lower() != "gpc" or w[2].lower() != "mode-tb":
        raise bad
    try:
        gpc = int(w[1])
    except ValueError:
        raise bad
    state = {"BARBERPOLE": "BP"}.get(w[3].upper(), w[3].upper())
    if not 1 <= gpc <= 5 or state not in TALKBACK_STATES:
        raise bad
    return {"kind": "wait", "gpc": gpc, "state": state, "timeout": timeout}


def screen_text(lines):
    """Two display lines -> (text to search for a title, key for a new screen):
    spaces squeezed and case folded; the key also drops the clocks."""
    text = " ".join(" ".join(lines).split()).upper()
    return text, SCREEN_CLOCK.sub("#", text)


PARAM_RE = re.compile(r"\$(?:\{(\w+)\}|(\w+))")


def substitute_params(text, params, where):
    """Fill in $NAME and ${NAME} through a called script from the NAME=VALUE
    pairs on the 'script' line that called it, so one procedure written once
    can be played for each GPC in turn.  Returns the filled text and the names
    that were actually used, and raises ScriptError -- naming the file and the
    line -- for a $NAME nobody supplied.  $$ is a literal $."""
    used, out = set(), []
    for n, raw in enumerate(text.splitlines(), 1):
        def one(m):
            name = m.group(1) or m.group(2)
            if name not in params:
                raise ScriptError("%s line %d: nothing given for $%s -- the "
                                  "'script' line that plays %s must say %s=VALUE"
                                  % (where, n, name, where, name))
            used.add(name)
            return params[name]
        # $$ means a literal $: split on it first so the halves are filled in
        # separately and the doubled one can never look like a name.
        out.append("$".join(PARAM_RE.sub(one, piece) for piece in raw.split("$$")))
    return "\n".join(out), used


def script_call(arg):
    """'FILE NAME=VALUE ...' from a script line -> (file, {NAME: VALUE})."""
    try:
        tokens = shlex.split(arg)
    except ValueError as err:
        raise ScriptError("script %s: %s" % (arg, err))
    if not tokens:
        raise ScriptError("script needs a file name")
    params = {}
    for tok in tokens[1:]:
        name, eq, value = tok.partition("=")
        if not eq or not re.fullmatch(r"\w+", name):
            raise ScriptError("a script's arguments are NAME=VALUE, and %r is not "
                              "one -- as in 'script ipl.script gpc=1'" % tok)
        if name in params:
            raise ScriptError("%s given twice" % name)
        params[name] = value
    return tokens[0], params


def parse(text, path=None, _depth=0, _seen=None):
    """The whole script -> entries in running order, each a dict with 'line':
    {'kind': 'wait', 'gpc', 'state', 'timeout', 'text'} or
    {'kind': 'step', 'ms', 'verb', 'arg', 'keys' (for keys lines), 'text'}.
    A 'script FILE' line is read here too, and its own entries hang off the
    step as 'entries', so a whole tree of scripts is checked before any of it
    runs.  path is the file text came from, which is what a relative FILE is
    relative to.  Raises ScriptError naming the line."""
    entries, last_ms = [], 0
    _seen = set(_seen or ())
    if path:
        _seen.add(os.path.realpath(path))
    # A SCRIPT WITH $NAMES IN IT IS A CALLED SCRIPT, and nothing has filled
    # them in, so every line it appears on would fail its argument check with
    # a message about the wrong thing ("'gpc $gpc': expected 'gpc 1-5'").  Say
    # what is actually wrong instead.
    if _depth == 0:
        names = sorted({(m.group(1) or m.group(2))
                        for line in text.splitlines()
                        for piece in line.split("$$")
                        for m in PARAM_RE.finditer(piece)})
        if names:
            raise ScriptError("%s takes arguments (%s), so it is played BY another "
                              "script, which fills them in -- and it is checked when "
                              "that script is checked.  Write $$ for a literal $."
                              % (os.path.basename(path) if path else "this script",
                                 ", ".join("$" + n for n in names)))
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
                entry = parse_wait(rest)
                entry.update({"text": line, "line": n})
                entries.append(entry)
                last_ms = 0
                continue
            # '+N': N seconds after the line before (or after the start or the
            # last wait), resolved here, so the player sees only the sum.
            rel = first.startswith("+")
            try:
                seconds = float(first[1:] if rel else first)
            except ValueError:
                raise ScriptError("expected '<seconds> <command>', '+<seconds> <command>' "
                                  "or 'wait ...', got %r" % line)
            if seconds != seconds or seconds < 0 or seconds == float("inf"):
                raise ScriptError("bad time %r" % first)
            if seconds > MAX_SCRIPT_SECONDS:
                raise ScriptError("%s seconds is over %d -- script times are SECONDS, "
                                  "not milliseconds (divide by 1000)"
                                  % (first, MAX_SCRIPT_SECONDS))
            ms = int(round(seconds * 1000)) + (last_ms if rel else 0)
            if ms < last_ms:
                raise ScriptError("time %s is earlier than the line before it -- lines run "
                                  "in file order, so times may not go backwards between waits "
                                  "(+%s would mean %s seconds after it)" % (first, first, first))
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
            elif verb == "script":
                if not arg:
                    raise ScriptError("script needs a file name")
                sub, params = script_call(arg)
                if not os.path.isabs(sub):
                    sub = os.path.join(os.path.dirname(os.path.abspath(path or ".")), sub)
                real = os.path.realpath(sub)
                if real in _seen:
                    raise ScriptError("%s calls itself (directly or through another script)"
                                      % os.path.basename(sub))
                if _depth + 1 > MAX_SCRIPT_DEPTH:
                    raise ScriptError("scripts call each other more than %d deep"
                                      % MAX_SCRIPT_DEPTH)
                try:
                    with open(sub) as fh:
                        sub_text = fh.read()
                except OSError as err:
                    raise ScriptError("cannot read %s: %s" % (sub, err))
                # FILLED IN BEFORE IT IS PARSED, so what is checked is what
                # will run -- a bad GPC number reached through $gpc is caught
                # here, not part way through the run.
                sub_text, used = substitute_params(sub_text, params,
                                                   os.path.basename(sub))
                spare = set(params) - used
                if spare:
                    raise ScriptError("%s never uses %s"
                                      % (os.path.basename(sub),
                                         ", ".join("$" + u for u in sorted(spare))))
                entry["params"] = params
                try:
                    entry["entries"] = parse(sub_text, sub, _depth + 1, _seen | {real})
                except ScriptError as err:
                    raise ScriptError("in %s: %s" % (os.path.basename(sub), err))
                entry["path"] = sub
                # AND THE TIMES AFTER IT START AGAIN, exactly as they do after
                # a wait: Player._call resets the caller's origin when the
                # called script finishes, so a '+N' below this line means N
                # seconds after it came back.  Without this the line kept the
                # whole segment's accumulated time and was then measured from
                # that new origin, so it ran that much too late.
                last_ms = 0
            elif verb not in PANEL_VERBS:
                raise ScriptError("unknown command %r" % verb)
            elif not re.fullmatch(PANEL_ARGS[verb], arg, re.IGNORECASE):
                raise ScriptError("%r: expected '%s'" % (rest, PANEL_USAGE[verb]))
            entries.append(entry)
        except ScriptError as e:
            raise ScriptError("script line %d: %s" % (n, e))
    return entries


def has_wait_user(text):
    """Does this script wait for a person?  Then it needs a window to click.
    Text only, so a 'script FILE' line's contents are not seen -- use
    needs_user(parse(text, path)) when the file is to hand."""
    for raw in text.splitlines():
        w = raw.split("#", 1)[0].split()
        if len(w) == 2 and w[0].lower() == "wait" and w[1].lower() == "user":
            return True
    return False


def needs_user(entries):
    """Does this script, or any script it calls, wait for a person?"""
    for e in entries:
        if e["kind"] == "wait_user":
            return True
        if e.get("entries") and needs_user(e["entries"]):
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


def send_control(text, port_base=None, sock=None):
    """Tell panelO6.py to play a script or stop the one it is playing:
    'play <file>' or 'stop', one UTF-8 datagram on port base + 92.  Any
    program can send one; manager.py does."""
    own = sock is None
    if own:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + CONTROL_OFFSET))
    finally:
        if own:
            sock.close()


def send_session(text, port_base=None):
    """Tell simulatePASS.py to snapshot, resume or shut down: one UTF-8
    datagram on port base + 93.

    A SEPARATE PORT FROM send_control's, because a different program is
    listening.  panelO6 owns base+92 and understands play/stop/save, which
    are things a panel can do to itself; these are things only the process
    that LAUNCHED the run can do, since it alone holds the children and
    knows the configuration they were started with."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + SESSION_OFFSET))
    finally:
        sock.close()


def session_receiver(port_base=None):
    """The socket simulatePASS.py listens on for those."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("", base + SESSION_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def control_receiver(port_base=None):
    """The socket panelO6.py listens on for those commands."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("", base + CONTROL_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP), socket.inet_aton(D.IFACE)))
    return s


def count_entries(entries):
    """(steps, waits) in this script and every script it calls."""
    steps = waits = 0
    for e in entries:
        if e["kind"] == "step":
            steps += 1
        else:
            waits += 1
        if e.get("entries"):
            s2, w2 = count_entries(e["entries"])
            steps += s2
            waits += w2
    return steps, waits


class ScreenWatch(object):
    """Listens for MEDS2.py's screen announcements (port base + 91): the top
    two text lines of each DPS display, by MDU name.  A thread records them;
    latest(name) and settled() are safe to call from the host's loop."""

    def __init__(self):
        self._lock = threading.Lock()
        self._screens = {}
        self._started = time.monotonic()
        threading.Thread(target=self._listen, daemon=True).start()

    def _listen(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind(("", D.PORT_BASE + SCREEN_OFFSET))
            s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                         struct.pack("4s4s", socket.inet_aton(D.GROUP),
                                     socket.inet_aton(D.IFACE)))
        except OSError:
            return
        while True:
            try:
                data, _ = s.recvfrom(4096)
            except OSError:
                return
            parts = data.decode("utf-8", errors="replace").split("\n")
            if len(parts) < 2:
                continue
            with self._lock:
                self._screens[parts[0].strip().lower()] = screen_text(parts[1:3])

    def latest(self, name):
        """(title text, new-screen key) last heard from that MDU, or None."""
        with self._lock:
            return self._screens.get(name)

    def settled(self):
        return time.monotonic() - self._started >= SCREEN_SETTLE_S


class Player(object):
    """Runs parsed entries on the host's event loop.

    after(ms, fn)       schedule fn (Tk's root.after)
    panel(verb, arg)    carry out a panel command
    talkback(gpc)       'RUN', 'IPL' or 'BP' for GPC N now
    log(text)           report what happened
    wait_user(done)     optional: let a person say go, calling done() when
                        they do; without it a 'wait user' stops the script
    screens             optional: a ScreenWatch; without it a 'wait crt'
                        stops the script
    """

    def __init__(self, entries, after, panel, talkback, log, bus=None, wait_user=None,
                 screens=None, on_done=None):
        self.entries, self.after, self.panel = entries, after, panel
        self.talkback, self.log = talkback, log
        self.wait_user = wait_user
        self.screens = screens
        self.on_done = on_done         # called (stopped) when this script ends
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
            if e["kind"] == "step" and e["verb"] == "script":
                due = self.origin + e["ms"] / 1000.0 - time.monotonic()
                if due > 0:
                    self.after(int(due * 1000) + 1, lambda k=k: self._run(k))
                    return
                self.log("%s  [%d lines]" % (e["text"], len(e["entries"])))
                self._call(k, e)
                return
            if e["kind"] == "wait_screen":
                if self.screens is None:
                    self.log("%s: no screen announcements to follow -- script stopped"
                             % e["text"])
                    self.stopped = True
                    return
                self.log(e["text"])
                self._poll_screen(k, e, time.monotonic(), [False, None])
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
        if self.stopped and self.on_done:
            self.on_done(True)
            return
        if k >= len(self.entries) and self.on_done:
            self.on_done(False)
            return
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

    def _call(self, k, e):
        """Play a called script, then carry on with this one.  The caller's
        remaining times count from the moment the called script finished, as
        they do after a wait."""
        def done(stopped):
            if stopped:
                self.log("%s stopped inside %s -- script stopped"
                         % (e["text"], os.path.basename(e["path"])))
                self.stopped = True
                if self.on_done:
                    self.on_done(True)
                return
            self.log("back from %s" % os.path.basename(e["path"]))
            self.origin = time.monotonic()
            self._run(k + 1)

        child = Player(e["entries"], self.after, self.panel, self.talkback, self.log,
                       bus=self.bus, wait_user=self.wait_user, screens=self.screens,
                       on_done=done)
        child.start()

    def _poll_screen(self, k, e, begun, base):
        """base: [baseline taken, the new-screen key when it was]."""
        if self.stopped:
            return
        waited = time.monotonic() - begun
        cur = self.screens.latest(e["mdu"])
        met = False
        if e["title"] is not None:
            met = cur is not None and " ".join(e["title"].split()).upper() in cur[0]
        elif not base[0]:
            # The page on show when the wait began is not a new one.  Until the
            # watch has heard a round of announcements, nothing is known yet.
            if cur is not None or self.screens.settled():
                base[0], base[1] = True, cur[1] if cur is not None else None
        else:
            met = cur is not None and cur[1] != base[1] and not (base[1] is None and cur[1] == "")
        if met:
            self.log("wait met after %.1f s: %s  [%s: %s]"
                     % (waited, e["text"], e["mdu"], cur[0]))
            self.origin = time.monotonic()
            self._run(k + 1)
        elif waited > e["timeout"]:
            self.log("WAIT TIMED OUT after %.0f s: %s -- script stopped  [%s: %s]"
                     % (e["timeout"], e["text"], e["mdu"],
                        cur[0] if cur is not None else "nothing heard"))
            self.stopped = True
        else:
            self.after(WAIT_POLL_MS, lambda: self._poll_screen(k, e, begun, base))


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
            entries = parse(text, name)
        except (OSError, ScriptError) as e:
            print("%s: %s" % (name, e))
            bad += 1
            continue
        steps, waits = count_entries(entries)
        print("%s: ok, %d steps and %d waits%s"
              % (name, steps, waits,
                 " (including called scripts)" if any(e.get("entries") for e in entries) else ""))
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
