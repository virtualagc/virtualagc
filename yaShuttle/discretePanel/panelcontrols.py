"""The table-driven crew controls of panelO6.py's panel windows.

Every control added after the first panels (owner, 2026-10-02: "add all
remaining controls needed for the operation of PASS for all OPS at once") is
declared here as data -- what it looks like, which panel window it is on,
and which MDM contacts each of its positions closes -- and panelO6.py draws,
publishes, saves, restores and scripts it from this table alone.  crewscript
reads the same table to check a script's 'switch' and 'press' commands.

No Tk here, nothing but data and its checks.

A CONTROL is CONTROLS[key] = dict:
    panel      the numbered panel window it is on ("C3", "L2", ...)
    kind       "t2" / "t3"   a paddle switch, positions listed top to bottom
               "rot"         a rotary, positions listed anticlockwise-most
                             first (left to right across the top)
               "pb"          a momentary pushbutton
               "pbi"         a momentary pushbutton indicator (lighted)
    caption    printed above it ("\\n" for two lines)
    positions  for t2/t3/rot: the legends, as printed
    default    for t2/t3/rot: where it starts
    legend     for pb/pbi: what is printed on the button ("\\n" for two)
    contacts   which crew-contact bits are closed: for t2/t3/rot a dict
               {position: [(unit, dscrt, mask), ...]}; for pb/pbi a list
               [(unit, dscrt, mask), ...], closed while the button is held.
               unit 1-4 is FF1-4, 5-8 FA1-4 (yaGPC2 mdmdev.c's crew units);
               dscrt is the FF DSCRT word 1-13 (FA: 1-3), mask its bit(s).
    lamps      for pbi: [(unit, card, channel, mask), ...] -- lit when any
               of those DOH output bits is set
    hold_ms    for pb/pbi: how long a scripted 'press' holds it (500)
    sources    where this came from (flight source, SCOM page), as text

A PANE is a titled group of controls in rows: PANES[panel] is a list of
(title, [[key, key, ...], [key, ...]]), drawn in that order in the panel's
window after its older, hand-drawn panes.
"""

CONTROLS = {}
PANES = {}

KINDS = ("t2", "t3", "rot", "pb", "pbi")
FF_UNITS = (1, 2, 3, 4)
FA_UNITS = (5, 6, 7, 8)


def check():
    """Raise ValueError naming the first malformed entry, if any."""
    for key, c in CONTROLS.items():
        where = "panelcontrols %s" % key
        if c.get("kind") not in KINDS:
            raise ValueError("%s: kind %r" % (where, c.get("kind")))
        if not c.get("panel"):
            raise ValueError("%s: no panel" % where)
        if c["kind"] in ("t2", "t3", "rot"):
            pos = c.get("positions") or ()
            need = {"t2": 2, "t3": 3}.get(c["kind"])
            if (need and len(pos) != need) or len(pos) < 2:
                raise ValueError("%s: positions %r" % (where, pos))
            if c.get("default") not in pos:
                raise ValueError("%s: default %r not a position" % (where, c.get("default")))
            for p, cs in (c.get("contacts") or {}).items():
                if p not in pos:
                    raise ValueError("%s: contacts for %r, not a position" % (where, p))
                _check_contacts(where, cs)
        else:
            _check_contacts(where, c.get("contacts") or [])
            for lamp in c.get("lamps") or ():
                if len(lamp) != 4 or lamp[0] not in FF_UNITS:
                    raise ValueError("%s: lamp %r" % (where, lamp))
    for panel, panes in PANES.items():
        for title, rows in panes:
            for row in rows:
                for key in row:
                    if key not in CONTROLS:
                        raise ValueError("panelcontrols pane %s/%s: no control %r"
                                         % (panel, title, key))
                    if CONTROLS[key]["panel"] != panel:
                        raise ValueError("panelcontrols %s is on %s, not %s"
                                         % (key, CONTROLS[key]["panel"], panel))


def _check_contacts(where, cs):
    for u, d, m in cs:
        if u in FF_UNITS:
            ok = 1 <= d <= 13
        elif u in FA_UNITS:
            ok = 1 <= d <= 3
        else:
            ok = False
        if not ok or not 0 < m <= 0xFFFF:
            raise ValueError("%s: contact %r" % (where, (u, d, m)))


def positions_of(key):
    return CONTROLS[key].get("positions") or ()


def is_button(key):
    return CONTROLS[key]["kind"] in ("pb", "pbi")
