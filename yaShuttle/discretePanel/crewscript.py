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
import shutil
import subprocess
import socket
import struct
import sys
import threading
import time

import discretes as D

KEYBOARD_OFFSET = 30            # keyboard n's bus: port base + 30 + n
IDP_BUS_OFFSET = 40             # IDP n's bus: port base + 40 + n
SUBTITLE_OFFSET = 90            # subtitles.py: port base + 90
SCREEN_OFFSET = 91              # MEDS2.py's screen announcements: port base + 91
CONTROL_OFFSET = 92             # panelO6.py's script control: port base + 92
SESSION_OFFSET = 93             # simulatePASS.py's own control: port base + 93
RESULT_OFFSET = 94              # simulatePASS.py's answer to those: base + 94
MEDS_OFFSET = 95                # MEDS2.py's display-state control: base + 95
PROGRESS_OFFSET = 96            # how far panelO6.py's script has got: base + 96
HC_OFFSET = 86                  # crew scripts to handcontrollers.py: base + 86
HC_ACK_OFFSET = 87              # handcontrollers.py's acknowledgements: base + 87
RECORD_OFFSET = 89              # a person's actions, as script lines: base + 89
LPS_OFFSET = 108                # yaGPC2's ground Launch Processing System: base + 108


def idp_snapshot_files(n):
    """The two file names a display's state is saved under, as (json, mem).

    HERE, AND NOT IN EACH PROGRAM, because they have to agree and once did
    not.  MEDS2 named them after the LRU -- self.id is "IDP1", not "1" -- so
    it wrote idpIDP1.json and reported success, while simulatePASS waited for
    idp1.json and reported "missing idp1.json" with the file sitting beside
    it.  Two programs agreeing by convention is how that happens; one
    function they both call is how it stops.
    """
    digits = "".join(c for c in str(n) if c.isdigit()) or str(n)
    return "idp%s.json" % digits, "idp%s.mem.bin" % digits
# A settled ScreenWatch has heard at least one round of MEDS2.py's
# re-announcements (every 1 s), so "nothing heard" means a display is silent.
SCREEN_SETTLE_S = 2.5
SCREEN_CLOCK = re.compile(r"(\d+/)?\d\d:\d\d:\d\d")
MAX_SCRIPT_SECONDS = 36000
MAX_SCRIPT_DEPTH = 8            # a script calling a script calling a script...
WAIT_TIMEOUT_S = 600
KEY_GAP_S = 0.35
WAIT_POLL_MS = 100
# AUTOCIRCLE'S LEAD: a control's circle appears this long BEFORE the control
# moves, so the eye gets there first.  Circled after the move, the circle only
# ever pointed at something that had already happened (owner, 2026-10-05).
AUTOCIRCLE_LEAD_S = 1.0
# HOW LONG A 'snapshot' LINE WAITS for simulatePASS.py to say it is written.
# A capture stops every computer, writes each one's memory and each display's,
# and starts them again; seconds, not minutes, but a loaded host and five
# computers make "seconds" a wide word.  Long enough that a slow one is never
# mistaken for a broken one, short enough that a broken one does not hold a
# script for ever.
SNAPSHOT_TIMEOUT_S = 300.0
SNAPSHOT_POLL_MS = 200

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
# THE PANEL'S FEATURES BY NAME, for 'circle': every control panelO6 draws,
# named from what it is (panelO6.feature_name builds the same names from
# its controls).
_DAP_KEYS = (r"(a|b|auto|inrtl|lvlh|free|pri|alt|vern|roll_disc|roll_pulse|pitch_disc"
             r"|pitch_pulse|yaw_disc|yaw_pulse|x_norm|x_pulse|x_spare|y_norm|y_pulse"
             r"|low_z|z_norm|z_pulse|high_z)")
import panelcontrols as PC

PANEL_FEATURE = (r"(power|output|mode|ipl|modetb|outputtb)[1-5]|activity-mm[12]|iplsource|bfcdisplay|bfcselect|disengage"
                 r"|rhcengage-(cdr|plt)|kybdsel-(left|right)|(idppower|majfunc|idpload)[1-4]"
                 r"|adi-(l|r|a)-(att|err|rate)|attref-(l|r|a)|sense"
                 r"|dap-(c3|a6u)-" + _DAP_KEYS +
                 r"|fcs[1-4]|omseng-(left|right)|trim-(left|right)|xfeed"
                 r"|(bodyflap|spdbk)-(cdr|plt)"
                 + "".join("|" + re.escape(k) for k in sorted(PC.CONTROLS)))
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
    "adi": r"(l|r|a)\s+(att|attitude)\s+(inrtl|lvlh|ref)|(l|r|a)\s+(err|error|rate)\s+(high|med|low)",
    "sense": r"(-z|-x)",
    "attref": r"(l|r|a)",
    "dap": r"(c3|fwd|a6u|aft)\s+(a|b|auto|inrtl|lvlh|free|pri|alt|vern|roll_disc|roll_pulse|pitch_disc|pitch_pulse|yaw_disc|yaw_pulse|x_norm|x_pulse|y_norm|y_pulse|low_z|z_norm|z_pulse|high_z)",
    "fcs": r"[1-4]\s+(override|auto|off)",
    "omseng": r"(left|right)\s+(arm|arm/press|off)",
    "xfeed": r"(left|off|right)",
    "trim": r"(left|right)\s+(enable|inhibit)",
    "bodyflap": r"(cdr|plt)",
    "spdbk": r"(cdr|plt)",
    "switch": r"\S+\s+\S.*",
    "press": r"\S+",
    "circle": r"(" + PANEL_FEATURE + r")(\s+(#[0-9a-f]{6}|[a-z]+[0-9]*))?(\s+(\d+\.?\d*|\.\d+))?",
    "nocircle": r"",
    # autocircle [SECONDS] [COLOR] [DIAMETER]: a leading number is SECONDS.
    "autocircle": r"((\d+\.?\d*|\.\d+)(\s+(#[0-9a-f]{6}|[a-z]+[0-9]*))?(\s+(\d+\.?\d*|\.\d+))?"
                  r"|(#[0-9a-f]{6}|[a-z]+[0-9]*)(\s+(\d+\.?\d*|\.\d+))?|)",
    "gpcid": r"[1-5]",
    "bit": r"[ab]\s+\d+\s+" + _ON_OFF,
    # An MDU edgekey, by position under the display, 1-6 left to right.
    "edgekey": r"crt[1-4]\s+[1-6]",
    # The GROUND: a launch-sequence command from the Launch Processing System
    # over the launch data bus (yaGPC2's lpsmodel.c).
    "lps": r"(hold|resume|recycle|go_auto|go_engine|bypass_a|bypass_b|pogo"
           r"|gmtlo\s+[+=]\d+(\.\d+)?|code\s+\d+(\s+[0-9a-fA-F]{1,4})*)",
    # The hand controllers, through handcontrollers.py's window for that
    # station: a THC direction held for SECONDS, or an RHC axis deflected by
    # a FRACTION of full throw (-1 to 1) for SECONDS.
    "thc": r"(fwd|aft)\s+[+-][xyz]\s+(\d+\.?\d*|\.\d+)",
    "rhc": r"(lh|rh|aft)\s+(roll|pitch|yaw)\s+-?(1(\.0*)?|0?\.\d+|0)\s+(\d+\.?\d*|\.\d+)",
}
PANEL_USAGE = {
    "gpc": "gpc 1-5", "power": "power on|off", "output": "output backup|normal|terminate",
    "ipl": "ipl (no argument)", "mode": "mode halt|standby|run", "source": "source mm1|mm2|off",
    "display": "display on|off", "select": "select 1+2|2+3|3+1", "crt": "crt 0-3",
    "disengage": "disengage left|right", "rhcengage": "rhcengage cdr|plt",
    "bfsengage": "bfsengage on|off", "idppower": "idppower 1-4 on|off",
    "majfunc": "majfunc 1-4 gnc|sm|pl", "kybdsel": "kybdsel left 1|3, or kybdsel right 2|3",
    "idpload": "idpload 1-4", "gpcid": "gpcid 1-5", "bit": "bit a|b N on|off",
    "adi": "adi l|r|a att inrtl|lvlh|ref, or adi l|r|a err|rate high|med|low",
    "sense": "sense -z|-x", "attref": "attref l|r|a",
    "dap": "dap c3|a6u BUTTON (a b auto inrtl lvlh free pri alt vern roll_disc ... high_z)",
    "fcs": "fcs 1-4 override|auto|off", "omseng": "omseng left|right arm|arm/press|off",
    "xfeed": "xfeed left|off|right", "trim": "trim left|right enable|inhibit",
    "bodyflap": "bodyflap cdr|plt", "spdbk": "spdbk cdr|plt",
    "switch": "switch NAME POSITION -- a control from panelcontrols.py, as printed",
    "press": "press NAME -- a pushbutton from panelcontrols.py, held 0.5 s",
    "circle": "circle FEATURE [COLOR] [DIAMETER] -- see 'circle' in the help for FEATURE names",
    "nocircle": "nocircle (no argument)",
    "autocircle": "autocircle [SECONDS] [COLOR] [DIAMETER] -- SECONDS 1 unless given; 0 turns it off",
    "edgekey": "edgekey crt1-4 1-6 -- the MDU edgekey under that display, 1 = leftmost",
    "lps": "lps hold|resume|recycle|go_auto|go_engine|gmtlo +S|gmtlo =S|bypass_a|bypass_b|pogo"
           "|code N [hex ...]",
    "thc": "thc fwd|aft +x|-x|+y|-y|+z|-z SECONDS",
    "rhc": "rhc lh|rh|aft roll|pitch|yaw FRACTION SECONDS -- FRACTION of full throw, -1 to 1",
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


# '#' STARTS A COMMENT -- except as a #RRGGBB colour, which 'circle' takes:
# '#' then six hex digits then a word's end.
_COMMENT = re.compile(r"#(?![0-9a-fA-F]{6}\b).*$")


def check_table_control(verb, arg):
    """'switch NAME POSITION' / 'press NAME' against panelcontrols.py."""
    key, _, val = arg.strip().partition(" ")
    key = key.lower()
    if key not in PC.CONTROLS:
        raise ScriptError("%s: no control %r (panelcontrols.py)" % (verb, key))
    if verb == "press":
        if not PC.is_button(key):
            raise ScriptError("press %s: not a pushbutton; use 'switch %s POSITION'" % (key, key))
        return
    if PC.is_button(key):
        raise ScriptError("switch %s: a pushbutton; use 'press %s'" % (key, key))
    pos = PC.positions_of(key)
    if val.strip().upper() not in [p.upper() for p in pos]:
        raise ScriptError("switch %s: %r is not one of %s" % (key, val.strip(), " | ".join(pos)))


def strip_comment(raw):
    return _COMMENT.sub("", raw)


def _wrap(text, indent):
    import textwrap
    return textwrap.fill(text, 76, initial_indent=indent, subsequent_indent=indent)


# For --help screens: RawDescriptionHelpFormatter keeps the layout.
HELP = """\
  One command per line; '#' starts a comment (so a subtitle cannot contain
  one), except '#' and six hex digits, a colour; blank lines are ignored.  Every line is checked when the file is
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
                        --wait-user puts one first; --no-wait-user makes
                        every one, the script's own included, go straight on.
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
    audio FILE          play a sound, and carry straight on.  For telling
                        somebody that a long script has finished, or reached
                        a point worth coming back for.  FILE is relative to
                        the script, and its existence is checked when the
                        script is checked -- a name misspelt is found now
                        rather than at the moment it should have sounded.
    keygap SECONDS      (no time prefix, like wait) how far apart the keys of
                        a later 'keys' line are
                        typed (default %(gap)s).  Set it near the top of a
                        script meant to be WATCHED: a viewer being shown what
                        an ITEM entry is wants to see each key land.  It
                        applies to scripts this one calls, too.
    subtitle [TEXT]     show TEXT in the caption box (subtitles.py); no TEXT
                        clears it.  The two characters \\n start a new line;
                        a leading <left>, <center> or <right> aligns that
                        caption.

  capturing the vehicle as it goes:
    snapshot DIR        capture the whole vehicle into DIR -- every computer's
                        memory, every display's, the panel -- exactly as the
                        manager's SNAPSHOT Save does, and hold the script
                        until it is written.  DIR is relative to the script,
                        like 'script FILE' and 'audio FILE', and the directory
                        it will sit in must already exist, which is checked
                        when the script is checked.  The times after it begin
                        again, as they do after a wait, because the vehicle is
                        stopped while it is written and the wall clock is not.
                        Only the program that STARTED the run can do this, so
                        a script played into a simulation launched some other
                        way will say the capture timed out.

                        TWO USES, and the second is why it is worth
                        instrumenting a script heavily.  One is the obvious
                        saving of time: restart from the last capture instead
                        of paying the IPLs again.  The other is BISECTION -- a
                        failure that appears near the end of a long run can
                        only be studied by reaching it, and captures at each
                        milestone let a later session start just before the
                        interesting moment rather than forty minutes before
                        it.  A capture that fails does NOT stop the script:
                        losing the artefact is not a reason to lose the run.
                        How many were written, and how many failed, is said
                        when the script ends.
    enable snapshots
    disable snapshots   (no time prefix, like wait and keygap) turn every
                        'snapshot' line AFTER this one on or off, in this
                        script and in the scripts it calls.  Snapshots are on
                        to begin with.  This is what makes heavy
                        instrumentation practical: write as many captures as
                        bisecting a failure needs, and silence the lot from
                        one line when the run is wanted for something else --
                        no editing, and nothing to put back afterwards.

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
   The MDUs (MEDS2), not a crew panel:
    edgekey crtN K      press edgekey K (1-6, left to right) under CRT N; the
                        MDU runs it itself, as a click would
   The ground, not the crew -- the Launch Processing System's launch-sequence
   commands over the launch data bus (yaGPC2's lpsmodel.c; polling must be on:
   DPS UTILITY SPEC 1 ITEM 50 in OPS 9):
    lps gmtlo +S        GMT OF PREDICTED LIFTOFF, S seconds from now (only
                        accepted while the count is holding)
    lps gmtlo =S        the same, as absolute GPC GMT seconds
    lps resume          RESUME the count (needs a GMTLO since the last start)
    lps hold            COUNTDOWN HOLD; after engine start, a pad abort
    lps recycle         RECYCLE (while holding)
    lps go_auto         GO FOR AUTO SEQUENCE (by T-31 s)
    lps go_engine       GO FOR ENGINE START (by about T-10 s)
    lps bypass_a|bypass_b|pogo   the LO2 bleed and POGO recirculation bypasses
    lps code N [hex..]  any launch-sequence code, with data words
   The hand controllers (handcontrollers.py's window for that station must be
   running -- the manager's HAND CONTROLLERS buttons, or simulatePASS --rhc):
    thc fwd|aft DIR S   hold THC direction DIR (+x -x +y -y +z -z) for S s
    rhc lh|rh|aft AXIS F S
                        deflect that RHC's AXIS (roll pitch yaw) by F of full
                        throw (-1 to 1; past detent about 0.1, softstop about
                        0.9) for S s, then back to centre
   F6, F8 and A6U, the ADI switches (l CDR F6, r PLT F8, a aft A6U):
    adi S att inrtl|lvlh|ref
                        ADI ATTITUDE
    adi S err|rate high|med|low
                        ADI ERROR, ADI RATE
    attref S            ATT REF pushbutton, held 0.5 s
    sense -z|-x         A6U SENSE
   C3 (forward) and A6U (aft), the ORBITAL DAP pushbuttons, each held 0.5 s:
    dap c3|a6u a|b              SELECT A, B
    dap c3|a6u auto|inrtl|lvlh|free
                                CONTROL
    dap c3|a6u pri|alt|vern     RCS jets
    dap c3|a6u roll_disc|roll_pulse|pitch_disc|pitch_pulse|yaw_disc|yaw_pulse
                                ROTATION roll/pitch/yaw DISC RATE, PULSE
    dap c3|a6u x_norm|x_pulse|y_norm|y_pulse|z_norm|z_pulse|low_z|high_z
                                TRANSLATION
   C3, O7, F3, F2 and F4, the other switches PASS reads in OPS 2:
    fcs N override|auto|off     C3 FCS CHANNEL N (1-4)
    omseng left|right arm|arm/press|off
                                C3 OMS ENG
    xfeed left|off|right        O7 MASTER RCS CROSSFEED (FEED FROM LEFT/RIGHT)
    trim left|right enable|inhibit
                                F3 TRIM RHC/PNL (left end CDR, right end PLT)
    bodyflap cdr|plt            F2/F4 BODY FLAP AUTO/MAN pushbutton, held 0.5 s
    spdbk cdr|plt               F2/F4 SPD BK/THROT AUTO/MAN pushbutton, held 0.5 s
   the rest of the panels' controls, by name (panelcontrols.py lists them):
    switch NAME POSITION        a switch or rotary, by its printed position
    press NAME                  a pushbutton, held 0.5 s
   drawing attention, for demonstrations:
    circle FEATURE [COLOR] [DIAMETER]
                        a circle round that control, on top of the Panel,
                        until the next circle or nocircle; COLOR a colour name
                        or #RRGGBB (yellow), DIAMETER in pushbutton sizes (2)
    nocircle            take it away
    autocircle [SECONDS] [COLOR] [DIAMETER]
                        from now on circle every control the script moves,
                        from 1 s before each move to SECONDS (1) after it, and
                        the MODE talkback a 'wait gpc N mode-tb' is waiting
                        on, until it is met.  A move due sooner than 1 s
                        away (just after a wait, typing or the start) waits
                        for its circle, and the lines after it keep their
                        spacing;
                        COLOR and DIAMETER as for circle.  Independent of
                        circle and nocircle, and of each other: a control
                        can carry both.  Panel O6's windows only -- not
                        keys, edgekeys or hand controllers.  autocircle 0
                        turns it off and takes its circles away.
                        FEATURE names: power1-5 output1-5 mode1-5 ipl1-5
                        modetb1-5 outputtb1-5 (the MODE and OUTPUT
                        talkbacks) activity-mm1|mm2 (the ACTIVITY lamps);
                        and every panelcontrols.py name, its lamps,
                        talkbacks and annunciators included
                        iplsource bfcdisplay bfcselect disengage
                        rhcengage-cdr|plt idppower1-4 majfunc1-4 idpload1-4
                        kybdsel-left|right adi-l|r|a-att|err|rate
                        attref-l|r|a sense dap-c3|a6u-BUTTON (as for dap,
                        and x_spare) fcs1-4 omseng-left|right
                        trim-left|right xfeed bodyflap-cdr|plt spdbk-cdr|plt
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


# 'audio' ON OR OFF.  Playing a sound uses Linux's players (AUDIO_PLAYERS), so
# on another system a script with 'audio' lines could not be used at all:
# every one of them is checked for its file as the script is read.  --no-audio
# (simulatePASS.py, panelO6.py) turns them off: they are accepted without
# looking for the file, and skipped when reached.  It travels as
# NSTS_NO_AUDIO=1, which simulatePASS.py passes on to everything it starts,
# so the panel, the manager and any script they load all agree.
AUDIO = os.environ.get("NSTS_NO_AUDIO") != "1"


def disable_audio():
    """--no-audio: ignore every 'audio' line, here and in child processes."""
    global AUDIO
    AUDIO = False
    os.environ["NSTS_NO_AUDIO"] = "1"


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
        line = strip_comment(raw).strip()
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
            # NO TIME PREFIX, like 'wait': keygap does not HAPPEN at a moment,
            # it changes how the keys after it are typed.  Giving it a prefix
            # would invite '+2 keygap 1' and the question of what the 2 meant.
            # NO TIME PREFIX, like 'wait' and 'keygap': these do not HAPPEN
            # at a moment, they change what the snapshot lines AFTER them do.
            # The point is to instrument a script with as many captures as
            # bisecting a failure needs and then turn the lot off from one
            # line, without editing any of them.
            if first.lower() in ("enable", "disable") and not first[1:2].isdigit():
                # A NEAR MISS IS A TYPO, NOT A TIMED STEP.  Without this
                # 'enable snapshot' -- singular, which is the way it will be
                # written -- fell through to the time parser and was reported
                # as "expected '<seconds> <command>'", which points at the
                # wrong half of the line entirely.
                if rest.lower() != "snapshots":
                    raise ScriptError("%r: the only thing that can be enabled or "
                                      "disabled is 'snapshots' (plural)" % line)
                entries.append({"kind": "step", "ms": last_ms, "verb": "snapshots",
                                "arg": first.lower(),
                                "on": first.lower() == "enable",
                                "text": line, "line": n})
                continue

            if first.lower() == "keygap":
                try:
                    gap = float(rest)
                except ValueError:
                    raise ScriptError("keygap wants a number of seconds, got %r" % rest)
                if not 0.0 <= gap <= 10.0:
                    raise ScriptError("keygap out of range (0 to 10 s), got %r" % rest)
                entries.append({"kind": "step", "ms": last_ms, "verb": "keygap",
                                "arg": rest, "gap": gap, "text": line, "line": n})
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
            elif verb == "audio":
                # A SOUND AT A MOMENT THAT MATTERS.  A long script ends in
                # silence, and the person recording it is by then looking
                # somewhere else; the same goes for the few points in a run
                # worth being called back for.
                #
                # CHECKED HERE, with the rest of the script, because the
                # alternative is finding out that the file was misspelt at
                # the moment it was supposed to tell you something.
                if AUDIO:                 # --no-audio: not looked for, not played
                    if not arg:
                        raise ScriptError("audio needs a file name")
                    snd = arg
                    if not os.path.isabs(snd):
                        snd = os.path.join(os.path.dirname(os.path.abspath(path or ".")), snd)
                    if sys.platform == "darwin":
                        # macOS PLAYS WHAT IT CAN, AND A SOUND OF ITS OWN FOR
                        # THE REST.  The example scripts name Linux's desktop
                        # sounds (.oga, under /usr/share/sounds), which macOS
                        # neither has nor can play, and refusing the whole
                        # script for them would leave every demonstration
                        # unrunnable without --no-audio.  So a file afplay
                        # can play is kept; anything else becomes "", which
                        # play_audio() answers with MAC_AUDIO_FALLBACK -- the
                        # cue still sounds, just not the sound named.
                        entry["audio"] = (snd if os.path.isfile(snd) and
                                          os.path.splitext(snd)[1].lower() in MAC_AUDIO_TYPES
                                          else "")
                    elif sys.platform == "win32":
                        # WINDOWS DOES THE SAME, with winsound, which plays
                        # .wav only: a .wav that is there is kept, and anything
                        # else becomes "", Windows' own notification sound.
                        entry["audio"] = (snd if os.path.isfile(snd) and
                                          snd.lower().endswith(".wav") else "")
                    elif not os.path.isfile(snd):
                        raise ScriptError("audio: no such file: %s" % arg)
                    else:
                        entry["audio"] = snd

            elif verb == "snapshot":
                # WHERE, CHECKED NOW.  A capture is the one step in a script
                # whose whole value is the file it leaves behind, so a name
                # that cannot be written is worth knowing about before the
                # run rather than thirty minutes into it.  Relative to the
                # SCRIPT, as 'script FILE' and 'audio FILE' are: a script and
                # the captures it takes belong together.
                if not arg:
                    raise ScriptError("snapshot needs a directory name")
                if arg.split()[0] != arg:
                    raise ScriptError("snapshot takes one directory name, got %r "
                                      "-- quote it or take the spaces out" % arg)
                where = arg
                if not os.path.isabs(where):
                    where = os.path.join(os.path.dirname(os.path.abspath(path or ".")),
                                         where)
                parent = os.path.dirname(os.path.abspath(where)) or "."
                if not os.path.isdir(parent):
                    raise ScriptError("snapshot: %s has no directory %s to write in"
                                      % (arg, parent))
                entry["snapdir"] = os.path.abspath(where)
                # AND THE TIMES AFTER IT START AGAIN, as they do after a wait
                # and after a called script.  A capture stops the vehicle for
                # as long as it takes to write it, and the wall clock does not
                # stop with it -- so a '+5' below this line has to mean five
                # seconds after the capture finished, not five seconds after
                # the line was due, which is already in the past by then.
                last_ms = 0
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
            elif verb in ("switch", "press"):
                check_table_control(verb, arg)
            entries.append(entry)
        except ScriptError as e:
            raise ScriptError("script line %d: %s" % (n, e))
    return entries


def has_wait_user(text):
    """Does this script wait for a person?  Then it needs a window to click.
    Text only, so a 'script FILE' line's contents are not seen -- use
    needs_user(parse(text, path)) when the file is to hand."""
    for raw in text.splitlines():
        w = strip_comment(raw).split()
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


def send_result(text, port_base=None):
    """simulatePASS's answer to a session command, on port base + 94.

    A SEPARATE PORT AND NOT A REPLY, because the asker is a GUI: manager
    sends and returns to its event loop at once, and a save takes seconds.
    Without this the only record of a failure is simulatePASS's terminal log
    -- and not having to watch that terminal is the whole reason the manager
    window exists.  A save that failed would have looked exactly like one
    that worked, which is the failure this feature is meant to remove."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + RESULT_OFFSET))
    finally:
        sock.close()


def result_receiver(port_base=None):
    """The socket manager.py listens on for those answers."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", base + RESULT_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


AUDIO_PLAYERS = (
    ("paplay", ()),                       # PulseAudio: .oga, .ogg, .wav, .flac
    ("aplay", ("-q",)),                   # ALSA: .wav
    ("ffplay", ("-nodisp", "-autoexit", "-loglevel", "quiet")),
)


# macOS: afplay, which every macOS has, and what it can play.  Not .oga or
# .ogg -- the format of Linux's desktop sounds -- which is why parse() turns
# those into the fallback, one of macOS's own alert sounds.
MAC_AUDIO_TYPES = (".wav", ".aif", ".aiff", ".aifc", ".mp3", ".m4a", ".caf")
MAC_AUDIO_FALLBACK = "/System/Library/Sounds/Glass.aiff"


def play_audio(path, log=None):
    """Start FILE playing and return at once.

    NOT WAITED FOR.  This exists to tell somebody that a script has reached a
    point, and a script that stopped for the length of the sound would be
    reporting its own progress dishonestly -- the run would pause exactly
    where the recording should not.

    Whichever player is installed; the sounds a desktop already ships are
    .oga, which aplay cannot read and paplay can, so the order matters.
    On macOS it is afplay, and "" means the fallback sound (see parse()).
    On Windows it is Python's own winsound, which needs no player, and ""
    means Windows' notification sound."""
    if sys.platform == "win32":
        try:
            import winsound
            if path:
                winsound.PlaySound(path, winsound.SND_FILENAME | winsound.SND_ASYNC
                                   | winsound.SND_NODEFAULT)
            else:
                winsound.PlaySound("SystemAsterisk", winsound.SND_ALIAS | winsound.SND_ASYNC)
            return True
        except (ImportError, RuntimeError) as e:
            if log:
                log("audio: could not play %s: %s" % (path or "the system sound", e))
            return False
    if sys.platform == "darwin":
        try:
            subprocess.Popen(["afplay", path or MAC_AUDIO_FALLBACK],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             stdin=subprocess.DEVNULL)
            return True
        except OSError as e:
            if log:
                log("audio: afplay would not start: %s" % e)
            return False
    for prog, flags in AUDIO_PLAYERS:
        if shutil.which(prog) is None:
            continue
        try:
            subprocess.Popen([prog] + list(flags) + [path],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             stdin=subprocess.DEVNULL)
            return True
        except OSError as e:
            if log:
                log("audio: %s would not start: %s" % (prog, e))
            return False
    if log:
        log("audio: nothing to play %s with (tried %s)"
            % (path, ", ".join(p for p, _ in AUDIO_PLAYERS)))
    return False


def send_progress(text, port_base=None, sock=None):
    """Say how far the running script has got: "<done> <total> <what>", or
    "done" when it ends.  One datagram on port base + 96.

    SENT RATHER THAN SHOWN, because the program that KNOWS is not the program
    anybody is looking at.  panelO6 plays the script, and its own window is
    small and often behind something; the manager is where a person watches a
    run from.  It is also fire-and-forget: nobody has to be listening, and a
    run with no manager is unaffected."""
    own = sock is None
    if own:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + PROGRESS_OFFSET))
    except OSError:
        pass                      # a progress report is never worth a failure
    finally:
        if own:
            sock.close()


def progress_receiver(port_base=None):
    """The socket manager.py listens on for those reports."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", base + PROGRESS_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def send_meds(text, port_base=None):
    """Tell every MEDS2 on this port base to save its display state.

    ONE DATAGRAM TO ALL OF THEM.  A run has one MEDS2 process per CRT and
    each owns different IDPs, so the request is multicast and each writes the
    units it actually has -- rather than simulatePASS needing to know which
    process holds which unit."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + MEDS_OFFSET))
    finally:
        sock.close()


def send_lps(text, port_base=None):
    """A launch-sequence command for yaGPC2's ground model: "LPS1 " and the
    command line, one datagram on port base + 108."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(("LPS1 " + text).encode("utf-8"), (D.GROUP, base + LPS_OFFSET))
    finally:
        sock.close()


def send_hc(text, port_base=None):
    """A crew-script command for handcontrollers.py, on port base + 86.  Each
    running instance takes the ones for its own station and acknowledges on
    base + 87 (hc_ack_receiver), so a command nobody took can be reported."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + HC_OFFSET))
    finally:
        sock.close()


def _group_receiver(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", port))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def hc_receiver(port_base=None):
    """The socket handcontrollers.py listens on for send_hc's commands."""
    return _group_receiver((D.PORT_BASE if port_base is None else port_base) + HC_OFFSET)


def hc_ack_receiver(port_base=None):
    """The socket panelO6.py hears handcontrollers.py's acknowledgements on."""
    return _group_receiver((D.PORT_BASE if port_base is None else port_base) + HC_ACK_OFFSET)


def send_hc_ack(text, port_base=None):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
    sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
    try:
        base = D.PORT_BASE if port_base is None else port_base
        sock.sendto(text.encode("utf-8"), (D.GROUP, base + HC_ACK_OFFSET))
    finally:
        sock.close()


def send_record(source, line, port_base=None):
    """WHAT A PERSON JUST DID, AS THE SCRIPT LINE THAT WOULD DO IT, for
    recordscript.py on port base + 89.  Sent by the program the person used
    (panelO6, a keyboard, an MDU) whether or not anything is recording: one
    datagram per action costs nothing, and a recording can then start at any
    moment.  Never by a script's own actions, which are not the person's."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF, socket.inet_aton(D.IFACE))
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_LOOP, 1)
        try:
            base = D.PORT_BASE if port_base is None else port_base
            sock.sendto(("%s\t%s" % (source, line)).encode("utf-8"),
                        (D.GROUP, base + RECORD_OFFSET))
        finally:
            sock.close()
    except OSError:
        pass


def record_receiver(port_base=None):
    """The socket recordscript.py listens on for send_record's lines."""
    return _group_receiver((D.PORT_BASE if port_base is None else port_base) + RECORD_OFFSET)


def meds_receiver(port_base=None):
    """The socket each MEDS2 listens on for those."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", base + MEDS_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def session_receiver(port_base=None):
    """The socket simulatePASS.py listens on for those."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
    s.bind(("", base + SESSION_OFFSET))
    s.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP,
                 struct.pack("4s4s", socket.inet_aton(D.GROUP),
                             socket.inet_aton(D.IFACE)))
    return s


def control_receiver(port_base=None):
    """The socket panelO6.py listens on for those commands."""
    base = D.PORT_BASE if port_base is None else port_base
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    D.share_port(s)
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
            D.share_port(s)
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

    def all(self):
        """{MDU name: (title text, key)} for every MDU heard."""
        with self._lock:
            return dict(self._screens)


class Player(object):
    """Runs parsed entries on the host's event loop.

    after(ms, fn)       schedule fn (Tk's root.after)
    panel(verb, arg)    carry out a panel command
    talkback(gpc)       'RUN', 'IPL' or 'BP' for GPC N now
    log(text)           report what happened
    wait_user(done)     optional: let a person say go, calling done() when
                        they do; without it a 'wait user' stops the script
    unattended          nobody is there to click: every 'wait user' is met at
                        once, in this script and every one it calls
    screens             optional: a ScreenWatch; without it a 'wait crt'
                        stops the script
    marks(e, on)        optional: told when a wait on a panel control (a
                        'wait gpc N mode-tb') begins (on) and when it ends,
                        met, timed out or stopped (off) -- autocircle
    plan(steps)         optional, with circle: [(verb, arg), ...] -> for each,
                        what autocircle will circle when it runs ([] for
                        nothing); circle(that) shows it AUTOCIRCLE_LEAD_S
                        ahead of the step.  See _plan.
    """

    def __init__(self, entries, after, panel, talkback, log, bus=None, wait_user=None,
                 screens=None, on_done=None, progress=None, counter=None,
                 source=None, gap=None, snaps=None, unattended=False, marks=None,
                 plan=None, circle=None):
        self.entries, self.after, self.panel = entries, after, panel
        self.marks = marks
        self.plan, self.circle = plan, circle
        self._plan_end = 0          # entries before this are planned (_plan)
        self.talkback, self.log = talkback, log
        self.wait_user = wait_user
        self.unattended = unattended
        self.screens = screens
        self.on_done = on_done         # called (stopped) when this script ends
        self.bus = bus or Bus()
        self.origin = None
        self.stopped = False
        # WHERE THE SCRIPT HAS GOT TO, for anyone watching rather than
        # reading the log.  A run whose script is still working and one whose
        # script ended twenty minutes ago look identical on screen, which is
        # no way to watch a simulation: the owner sat through an eyes-on run
        # unable to tell whether the configuration he was looking at was the
        # final one or a half-built one (2026-09-22).
        #
        # Captions can say so, but only if the script's author wrote them AND
        # subtitles.py is running, which needs --layout.  This is the channel
        # that is always there.
        #
        # The counter is SHARED WITH NESTED SCRIPTS -- a 'script FILE' step
        # plays its children on a Player of their own, and progress through
        # them is progress through the whole run -- so a caller passes none
        # and children inherit the parent's.
        self.progress = progress
        self.counter = counter
        if self.counter is None and progress is not None:
            steps, waits = count_entries(entries)
            self.counter = {"done": 0, "total": steps + waits}
        self._reported = -1
        # WHICH FILE THESE ENTRIES CAME FROM, so a report can say where the
        # script has got to and not merely how far.  A count alone cannot be
        # looked up: a 'script FILE' line counts as one PLUS all of its
        # children, so a 150-line script that calls a 20-line one five times
        # reports over 200 entries and no line of it matches any of them.
        self.source = source
        # Shared with nested scripts, so a 'keygap' near the top of a script
        # governs the keys typed by the scripts it calls as well.
        self.gap = gap if gap is not None else [KEY_GAP_S]
        # THE SAME FOR SNAPSHOTS, and for the same reason: 'disable snapshots'
        # at the top of a script has to reach the captures inside the scripts
        # it calls, or turning them off means finding every one of them.
        # 'taken' and 'failed' are counted here so that the end of the run can
        # say whether the captures it was instrumented for actually exist.
        self.snaps = snaps if snaps is not None else {"on": True, "taken": 0,
                                                      "failed": 0}

    def start(self):
        self.origin = time.monotonic()
        self.after(0, lambda: self._run(0))

    def _note(self, k, e):
        """Say where the script has got to, once per entry.  _run is
        re-entered for the same entry whenever a step is not yet due, so the
        highest entry reached is what counts rather than the number of
        visits."""
        if self.progress is None or k <= self._reported:
            return
        self._reported = k
        self.counter["done"] += 1
        text = (e.get("text") or e.get("kind") or "").strip()
        where = ""
        if e.get("line"):
            where = "%s:%d" % (self.source or "?", e["line"])
        self.progress(self.counter["done"], self.counter["total"], text, where)

    def _run(self, k):
        while k < len(self.entries) and not self.stopped:
            e = self.entries[k]
            if k >= self._plan_end:
                self._plan(k)
            self._note(k, e)
            if e["kind"] == "wait_user" and self.unattended:
                # --no-wait-user means NO waiting for a person, whoever asked
                # for it -- the script's own 'wait user' as much as the one
                # --wait-user would have put first.  It used to cover only the
                # latter, and an unattended run of a script with its own
                # waited for ever (4gpc-startup-subtitled, 2026-09-27).
                self.log("%s: unattended, going straight on" % e["text"])
                k += 1
                continue
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
                self._mark(e, True)
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
            if e["verb"] == "snapshots":
                # Not a panel control either: it changes what the snapshot
                # lines after it do, here and in any script this one calls.
                self.snaps["on"] = e["on"]
                self.log(e["text"])
                k += 1
                continue
            if e["verb"] == "snapshot":
                if not self.snaps["on"]:
                    self.log("%s -- not taken ('disable snapshots' is in force)"
                             % e["text"])
                    # AND THE ORIGIN MOVES ANYWAY.  The parser restarts the
                    # times after a snapshot line, as it does after a wait,
                    # because a capture stops the vehicle for as long as it
                    # takes to write.  That restart is decided when the script
                    # is READ and 'disable snapshots' is a state at RUN time,
                    # so the entries after this one carry times measured from
                    # here whether the capture happened or not.  Without this
                    # line they were measured from here against an origin set
                    # somewhere further back, every one of them was already
                    # overdue, and the whole rest of the script fired at once
                    # -- which would have turned "disable snapshots" from a
                    # way of silencing captures into a way of wrecking the run.
                    self.origin = time.monotonic()
                    k += 1
                    continue
                self.log(e["text"])
                self._snapshot(k, e)
                return
            if e["verb"] == "keygap":
                # Not a panel control: it changes how the NEXT keys are
                # typed, and the list is shared with any nested script.
                self.gap[0] = e["gap"]
                self.log(e["text"])
                k += 1
                continue
            if e["verb"] == "keys":
                self.log(e["text"])
                self._type(k, e["keys"], 0)
                return
            self.log(e["text"])
            if e["verb"] == "audio":
                if AUDIO and "audio" in e:
                    play_audio(e["audio"], self.log)
                else:
                    self.log("audio: skipped (--no-audio)")
                k += 1
                continue
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
        if k >= len(self.entries) and self.progress is not None and \
                self.counter["done"] >= self.counter["total"]:
            self.progress(self.counter["done"], self.counter["total"], None, "")
        if k >= len(self.entries) and self.on_done:
            self.on_done(False)
            return
        if k >= len(self.entries) and not self.stopped:
            # WHETHER THE CAPTURES IT WAS INSTRUMENTED FOR EXIST.  A script
            # whose snapshots all failed ends exactly like one whose snapshots
            # all worked, and the difference is only discovered later, when
            # the capture that was supposed to be bisected is not there.
            note = ""
            if self.snaps["taken"] or self.snaps["failed"]:
                note = " (%d snapshot(s) written%s)" % (
                    self.snaps["taken"],
                    ", %d FAILED" % self.snaps["failed"] if self.snaps["failed"] else "")
            self.log("script complete" + note)

    def _type(self, k, keys, i):
        if self.stopped:
            return
        if i < len(keys):
            try:
                self.bus.send_key(keys[i])
            except OSError as err:
                self.log("cannot send key %s: %s" % (keys[i][3], err))
            self.after(int(self.gap[0] * 1000), lambda: self._type(k, keys, i + 1))
        else:
            self._run(k + 1)

    # The lines that can hold the script for a time nobody knows in advance:
    # the run of timed lines a plan covers ends at the first of them.
    _BLOCKING = ("keys", "script", "snapshot")

    def _plan(self, k):
        """AUTOCIRCLE'S CIRCLES, A SECOND EARLY.  The timed lines from k up
        to the next wait, typing, called script or snapshot all have known
        times, so each control among them can be circled AUTOCIRCLE_LEAD_S
        before it moves.  When the first of them is due sooner than that --
        straight after a wait, at the start, after typing -- the whole run
        moves later by the shortfall, keeping its spacing: every line after
        the first is then at least as far off, so all of them get the lead."""
        steps = []
        for e in self.entries[k:]:
            if e["kind"] != "step" or e["verb"] in self._BLOCKING:
                break
            steps.append(e)
        self._plan_end = k + max(1, len(steps))
        if self.plan is None or self.circle is None or not steps:
            return
        try:
            names = self.plan([(e["verb"], e["arg"]) for e in steps])
        except Exception as err:         # never worth stopping a script for
            self.log("autocircle: %s" % err)
            return
        firsts = [e for e, n in zip(steps, names) if n]
        if not firsts:
            return
        now = time.monotonic()
        short = AUTOCIRCLE_LEAD_S - (self.origin + firsts[0]["ms"] / 1000.0 - now)
        if short > 0.0005:
            # Reported as how much LATER it now happens than it otherwise
            # would -- an overdue line would have gone at once, not when due.
            due = max(now, self.origin + firsts[0]["ms"] / 1000.0)
            self.origin += short
            held = self.origin + firsts[0]["ms"] / 1000.0 - due
            if held >= 0.01:
                self.log("autocircle: '%s' held %.2f s so that its circle shows first"
                         % (firsts[0]["text"], held))
        for e, n in zip(steps, names):
            if n:
                at = self.origin + e["ms"] / 1000.0 - AUTOCIRCLE_LEAD_S - now
                self.after(max(0, int(at * 1000)),
                           lambda n=n: None if self.stopped else self.circle(n))

    def _mark(self, e, on):
        if self.marks is not None:
            try:
                self.marks(e, on)
            except Exception as err:    # a circle is never worth stopping a script for
                self.log("autocircle: %s" % err)

    def _poll(self, k, e, begun):
        if self.stopped:
            self._mark(e, False)
            return
        waited = time.monotonic() - begun
        if self.talkback(e["gpc"]) == e["state"]:
            self.log("wait met after %.1f s: %s" % (waited, e["text"]))
            self._mark(e, False)
            self.origin = time.monotonic()
            self._run(k + 1)
        elif waited > e["timeout"]:
            self.log("WAIT TIMED OUT after %.0f s: %s -- script stopped"
                     % (e["timeout"], e["text"]))
            self._mark(e, False)
            self.stopped = True
        else:
            self.after(WAIT_POLL_MS, lambda: self._poll(k, e, begun))

    def _snapshot(self, k, e):
        """Ask simulatePASS.py to capture the vehicle, and hold the script
        until it says the capture is written.

        WHY IT WAITS.  The capture stops every computer, and the wall clock
        does not stop with them: a script that carried on would find every
        step after it already overdue and would fire them all at once.  So the
        script waits, and its times begin again from when the capture is
        written -- the parser sets those times up for it (see 'snapshot' in
        parse).

        WHY IT DOES NOT STOP THE SCRIPT WHEN A CAPTURE FAILS.  The capture is
        an artefact OF the run, not a step of it.  A script instrumented with
        a dozen of them to bisect a failure that takes half an hour to reach
        should not lose the half hour because a disk was full at minute six;
        it should lose the capture, say so loudly, and go on to the failure it
        was written to reach.  The count is reported when the script ends, so
        a run whose captures all failed cannot be mistaken for one whose
        captures are all there.  ('disable snapshots' is how you decline them
        deliberately; a failure is not that.)"""
        # THE SOCKET FIRST, THEN THE REQUEST.  An answer sent before anyone is
        # listening is an answer lost, and the loss would read as a timeout --
        # sending first left a race that showed up as a slow disk.
        try:
            sock = result_receiver()
        except OSError as err:
            self.log("snapshot: cannot listen for the answer: %s -- not taken" % err)
            self.snaps["failed"] += 1
            self.origin = time.monotonic()
            self._run(k + 1)
            return
        sock.setblocking(False)
        try:
            send_session("save %s" % e["snapdir"])
        except OSError as err:
            sock.close()
            self.log("snapshot: cannot ask for it: %s -- not taken" % err)
            self.snaps["failed"] += 1
            self.origin = time.monotonic()
            self._run(k + 1)
            return
        self.log("snapshot: writing %s -- the vehicle is stopped while it is"
                 % e["snapdir"])
        self._snapshot_poll(k, e, sock, time.monotonic())

    def _snapshot_poll(self, k, e, sock, begun):
        if self.stopped:
            sock.close()
            return
        waited = time.monotonic() - begun
        while True:
            try:
                text = sock.recv(4096).decode("utf-8", "replace").strip()
            except (BlockingIOError, OSError):
                break
            # THE ANSWER TO THIS QUESTION, not to somebody else's.  The result
            # channel carries the manager's saves and window placements too,
            # and a stray 'ok windows placed 7 window(s)' would otherwise be
            # read as this capture succeeding.
            word, _, rest = text.partition(" ")
            what, _, why = rest.partition(" ")
            # 'progress save N M' is the file count the manager's wait modal
            # shows while the capture is written -- not the verdict.
            if what != "save" or word == "progress":
                continue
            sock.close()
            self.origin = time.monotonic()
            if word == "ok":
                self.snaps["taken"] += 1
                self.log("snapshot: written after %.1f s: %s" % (waited, e["snapdir"]))
            else:
                self.snaps["failed"] += 1
                self.log("SNAPSHOT FAILED after %.1f s: %s (%s) -- the script "
                         "carries on without it" % (waited, e["snapdir"], why or word))
            self._run(k + 1)
            return
        if waited > SNAPSHOT_TIMEOUT_S:
            sock.close()
            self.snaps["failed"] += 1
            self.origin = time.monotonic()
            self.log("SNAPSHOT TIMED OUT after %.0f s: %s never answered -- is "
                     "simulatePASS.py the program that started this run?  The "
                     "script carries on without it." % (waited, e["snapdir"]))
            self._run(k + 1)
            return
        self.after(SNAPSHOT_POLL_MS,
                   lambda: self._snapshot_poll(k, e, sock, begun))

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
                       on_done=done, progress=self.progress, counter=self.counter,
                       source=os.path.basename(e["path"]), gap=self.gap,
                       snaps=self.snaps, unattended=self.unattended, marks=self.marks,
                       plan=self.plan, circle=self.circle)
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


def self_test():
    """Check the timing rules the snapshot commands depend on, with a fake
    clock and a fake event loop -- no simulation, no windows, no waiting.

    WHAT IT IS FOR.  'snapshot DIR' restarts the script's times where it
    stands, as a wait does, because a capture stops the vehicle for as long as
    it takes to write.  That restart is decided when the script is READ, while
    'disable snapshots' is a state at RUN time -- so a skipped capture has to
    move the clock exactly as a taken one would, or every line after it is
    already overdue and the rest of the script fires at once.  That would turn
    'disable snapshots' from a way of silencing captures into a way of
    wrecking the run, which is the opposite of the point.  Measured before the
    fix: 0, 3, 7 seconds where the script says 0, 5, 14."""
    script = ("disable snapshots\n"
              "+0   gpc 1\n"
              "+2   snapshot /tmp\n"
              "+3   gpc 2\n"
              "+4   snapshot /tmp\n"
              "+5   gpc 3\n")
    entries = parse(script, "self-test")
    pending, done, now = [], [], [0.0]

    class FakeBus(object):
        def send_subtitle(self, text): pass
        def send_key(self, key): pass

    player = Player(entries, lambda ms, fn: pending.append((now[0] + ms / 1000.0, fn)),
                    lambda verb, arg: done.append((round(now[0], 2), verb)),
                    lambda gpc: "RUN", lambda text: None, bus=FakeBus())
    player.origin = 0.0
    real = time.monotonic
    time.monotonic = lambda: now[0]
    try:
        player._run(0)
        for _ in range(500):
            if not pending:
                break
            pending.sort()
            now[0], fn = pending.pop(0)
            fn()
    finally:
        time.monotonic = real
    want = [(0.0, "gpc"), (5.0, "gpc"), (14.0, "gpc")]
    if done != want:
        print("FAIL: a disabled snapshot moved the clock wrongly\n"
              "  wanted %s\n  got    %s" % (want, done))
        return 1
    print("ok: 'disable snapshots' silences the captures and nothing else")
    return 0


def main(argv=None):
    import argparse
    import sys
    ap = argparse.ArgumentParser(
        description="Check crew scripts -- the files panelO6.py and simulatePASS.py\n"
                    "take with --script -- without running them.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="crew script commands:\n" + HELP)
    ap.add_argument("files", nargs="*", metavar="FILE", help="script to check")
    ap.add_argument("--self-test", action="store_true",
                    help="check this module's own timing rules and exit")
    args = ap.parse_args(argv)
    if args.self_test:
        return self_test()
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
