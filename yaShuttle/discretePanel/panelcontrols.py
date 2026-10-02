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
               "h3"          a paddle switch thrown sideways, positions
                             left, middle, right
               "pb"          a momentary pushbutton
               "pbi"         a momentary pushbutton indicator (lighted)
               "lamp"        an indicator only: lamps, no contacts
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
    spring     for switches: positions that spring back to the default when
               let go -- held only while the mouse is down, and for hold_ms
               when a script moves it there
    while_held for switches: the key of a pushbutton; the contacts close only
               while that button is held too (ABORT MODE with ABORT)
    guarded    for pb: drawn with a guard (appearance only)
    sources    where this came from (flight source, SCOM page), as text

A PANE is a titled group of controls in rows: PANES[panel] is a list of
(title, [[key, key, ...], [key, ...]]), drawn in that order in the panel's
window after its older, hand-drawn panes.
"""

CONTROLS = {}
PANES = {}

KINDS = ("t2", "t3", "h3", "rot", "pb", "pbi", "lamp")
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
        if c["kind"] in ("t2", "t3", "h3", "rot"):
            pos = c.get("positions") or ()
            need = {"t2": 2, "t3": 3, "h3": 3}.get(c["kind"])
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


def is_switch(key):
    return CONTROLS[key]["kind"] in ("t2", "t3", "h3", "rot")


def positions_of(key):
    return CONTROLS[key].get("positions") or ()


def is_button(key):
    return CONTROLS[key]["kind"] in ("pb", "pbi")


# ---------------------------------------------------------------------------
# THE GNC FLIGHT PANELS' CONTROLS, OPS 1/3/6 (and 8/9 for display): from the
# 2026-10-02 survey and its resolution against the flight source (GRASWI,
# CGRRMC, GDSSWP, GPEELV, GCTFCS, GFBRCS) and SCOM USA007587 Rev A
# Appendix A (L2 p.1044, C3 p.1052, F2/F4 p.1024, F6 p.1026, F8 p.1028,
# O7 p.1035, R2 p.1055).  FFk DSCRTn bit b = (k, n, 0x8000 >> (b - 1)); the
# F6/F8/O7 selectors are read from the MFE copy of the same words.

def _ff(units, dscrt, mask):
    return [(u, dscrt, mask) for u in units]


def _trims(side, units):
    """BODY FLAP and the three panel trim switches, one seat's (L2 CDR on
    FF1/FF2, C3 PLT on FF3/FF4); all spring back to the middle."""
    CONTROLS["bodyflap_" + side] = dict(
        panel="L2" if side == "cdr" else "C3", kind="t3", caption="BODY FLAP",
        positions=("UP", "AUTO/OFF", "DOWN"), default="AUTO/OFF", spring=("UP", "DOWN"),
        contacts={"UP": _ff(units, 1, 0x1000), "DOWN": _ff(units, 1, 0x0800)},
        sources="lever lock; UP/DOWN return to AUTO/OFF")
    CONTROLS["ptrim_" + side] = dict(
        panel=CONTROLS["bodyflap_" + side]["panel"], kind="t3", caption="PITCH\nTRIM",
        positions=("DOWN", "OFF", "UP"), default="OFF", spring=("DOWN", "UP"),
        contacts={"UP": _ff(units, 9, 0x4000), "DOWN": _ff(units, 9, 0x2000)},
        sources="UP = + = nose up (inferred from FSSR derotation)")
    for axis, cap, up, dn in (("rtrim", "ROLL\nTRIM", 0x1000, 0x0800),
                              ("ytrim", "YAW\nTRIM", 0x0400, 0x0200)):
        CONTROLS[axis + "_" + side] = dict(
            panel=CONTROLS["bodyflap_" + side]["panel"], kind="h3", caption=cap,
            positions=("L", "OFF", "R"), default="OFF", spring=("L", "R"),
            contacts={"R": _ff(units, 9, up), "L": _ff(units, 9, dn)},
            sources="R = +, L = -; GPGYAW")


_trims("cdr", (1, 2))
_trims("plt", (3, 4))

# C3: separation and main engines (OPS 1/6; the SEP pushbuttons also set
# weight-on-wheels by hand in OPS 3, GPILAN 218-220).
SEP = (1, 4, 3)
CONTROLS.update({
    "srb_sep_sw": dict(panel="C3", kind="t2", caption="SRB\nSEPARATION",
                       positions=("MAN/AUTO", "AUTO"), default="AUTO",
                       contacts={"AUTO": _ff(SEP, 5, 0x0400),
                                 "MAN/AUTO": _ff(SEP, 5, 0x0200)},
                       sources="GRASWI 744-762, GSESRB 439"),
    "srb_sep_pb": dict(panel="C3", kind="pb", caption="SRB SEP", legend="SEP",
                       guarded=True, contacts=_ff(SEP, 5, 0x0100)),
    "et_sep_sw": dict(panel="C3", kind="t2", caption="ET\nSEPARATION",
                      positions=("MAN", "AUTO"), default="AUTO",
                      contacts={"MAN": _ff(SEP, 13, 0x0400), "AUTO": _ff(SEP, 13, 0x0100)},
                      sources="lever lock"),
    "et_sep_pb": dict(panel="C3", kind="pb", caption="ET SEP", legend="SEP",
                      guarded=True, contacts=_ff(SEP, 13, 0x0200)),
    "me_limit": dict(panel="C3", kind="t3", caption="MAIN ENGINE\nLIMIT SHUT DN",
                     positions=("ENABLE", "AUTO", "INHIBIT"), default="AUTO",
                     contacts={"ENABLE": _ff((2, 3, 4), 3, 0x4000),
                               "INHIBIT": _ff((2, 3, 4), 3, 0x2000),
                               "AUTO": _ff((2, 3, 4), 3, 0x1000)}),
    "me_sd_left": dict(panel="C3", kind="pb", caption="LEFT", legend="SHUT\nDN",
                       guarded=True, contacts=_ff((2, 3), 7, 0x8000), sources="ME-2"),
    "me_sd_ctr": dict(panel="C3", kind="pb", caption="CTR", legend="SHUT\nDN",
                      guarded=True, contacts=_ff((1, 2), 1, 0x0400), sources="ME-1"),
    "me_sd_right": dict(panel="C3", kind="pb", caption="RIGHT", legend="SHUT\nDN",
                        guarded=True, contacts=_ff((3, 4), 1, 0x0400), sources="ME-3"),
})

# L2: entry mode and nose-wheel steering (the CDR's trims are above).
CONTROLS.update({
    "entry_mode": dict(panel="L2", kind="t3", caption="ENTRY\nMODE",
                       positions=("AUTO", "LO GAIN", "NO Y JET"), default="AUTO",
                       contacts={"LO GAIN": _ff((1, 2, 3, 4), 7, 0x1000),
                                 "NO Y JET": [(1, 3, 0x1000), (2, 1, 0x2000),
                                              (3, 10, 0x2000), (4, 11, 0x0001)]},
                       sources="lever lock; AUTO has no contact"),
    "nws": dict(panel="L2", kind="t3", caption="NOSE WHEEL\nSTEERING",
                positions=("2", "1", "OFF"), default="OFF",
                contacts={"1": [(2, 1, 0x0008)], "2": [(3, 10, 0x4000)]},
                sources="GPEELV 245-248"),
})

# F2 (CDR) / F4 (PLT): the flight-control-system AUTO and CSS pushbutton
# indicators, three contacts each; lamps on FF DOH card 10 channel 0, bit 7
# PITCH and bit 8 ROLL/YAW -- AUTO FF1 (left) / FF3 (right), CSS FF2 / FF4.
for side, panel, units, word, auto_u, css_u in (("cdr", "F2", (1, 2, 3), 2, 1, 2),
                                               ("plt", "F4", (2, 3, 4), 10, 3, 4)):
    for axis, cap, auto_m, css_m, lamp_m in (("pitch", "PITCH", 0x0020, 0x0010, 0x0200),
                                             ("ry", "ROLL/YAW", 0x0004, 0x0002, 0x0100)):
        CONTROLS["%s_auto_%s" % (axis, side)] = dict(
            panel=panel, kind="pbi", caption=cap, legend="AUTO",
            contacts=_ff(units, word, auto_m), lamps=[(auto_u, 10, 0, lamp_m)],
            sources="GCIGRT 471-628; lamps GCTFCS")
        CONTROLS["%s_css_%s" % (axis, side)] = dict(
            panel=panel, kind="pbi", caption=cap, legend="CSS",
            contacts=_ff(units, word, css_m), lamps=[(css_u, 10, 0, lamp_m)],
            sources="GCIGRT 471-628; lamps GCTFCS")

# F6 (CDR, MFE FF1) / F8 (PLT, MFE FF2): display selectors, processed in
# MM304/305/602/603 (GDSSWP 83).
for side, panel, u in (("cdr", "F6", 1), ("plt", "F8", 2)):
    CONTROLS.update({
        "air_data_" + side: dict(panel=panel, kind="t3", caption="AIR DATA",
                                 positions=("LEFT", "NAV", "RIGHT"), default="NAV",
                                 contacts={"LEFT": [(u, 1, 0x0004)], "NAV": [(u, 1, 0x0002)],
                                           "RIGHT": [(u, 1, 0x0001)]}),
        "hsi_mode_" + side: dict(panel=panel, kind="t3", caption="HSI\nMODE",
                                 positions=("ENTRY", "TAEM", "APPROACH"), default="ENTRY",
                                 contacts={"ENTRY": [(u, 10, 0x0800)], "TAEM": [(u, 10, 0x1000)],
                                           "APPROACH": [(u, 10, 0x2000)]}),
        "hsi_source_" + side: dict(panel=panel, kind="t3", caption="HSI\nSOURCE",
                                   positions=("TACAN", "NAV", "MLS"), default="NAV",
                                   contacts={"TACAN": [(u, 10, 0x4000)], "NAV": [(u, 10, 0x8000)],
                                             "MLS": [(u, 9, 0x0001)]},
                                   sources="Rev A appendix drawing prints GPS for TACAN"),
        "hsi_unit_" + side: dict(panel=panel, kind="t3", caption="HSI\nSOURCE",
                                 positions=("1", "2", "3"), default="1",
                                 contacts={"1": [(u, 10, 0x0100)], "2": [(u, 10, 0x0200)],
                                           "3": [(u, 10, 0x0400)]}),
        "rdr_altm_" + side: dict(panel=panel, kind="t2", caption="RDR\nALTM",
                                 positions=("1", "2"), default="1",
                                 contacts={"1": [(u, 9, 0x0004)], "2": [(u, 9, 0x0002)]}),
    })

# F6: ABORT MODE (contacts only while ABORT is pressed) and the RCS COMMAND
# lights, FF1 and FF3 DOH card 2 channel 1, bits 8-13.
CONTROLS.update({
    "abort_pb": dict(panel="F6", kind="pb", caption="", legend="ABORT", contacts=[],
                     sources="its red lamp is MCC's, not PASS's"),
    "abort_mode": dict(panel="F6", kind="rot", caption="ABORT MODE",
                       positions=("RTLS", "OFF", "ATO", "TAL"), default="OFF",
                       while_held="abort_pb",
                       contacts={"ATO": _ff((1, 2, 3), 11, 0x1000),
                                 "TAL": _ff((1, 2, 3), 11, 0x0800),
                                 "RTLS": _ff((1, 2, 3), 11, 0x0400)}),
})
for key, legend, mask in (("rcs_roll_l", "ROLL\nL", 0x0100), ("rcs_roll_r", "ROLL\nR", 0x0080),
                          ("rcs_yaw_l", "YAW\nL", 0x0040), ("rcs_yaw_r", "YAW\nR", 0x0020),
                          ("rcs_pitch_u", "PITCH\nUP", 0x0010), ("rcs_pitch_d", "PITCH\nDN", 0x0008)):
    CONTROLS[key] = dict(panel="F6", kind="lamp", caption="", legend=legend,
                         lamps=[(1, 2, 1, mask), (3, 2, 1, mask)], sources="GFBRCS 1515-1535")

# O7: TACAN MODE x3; only GPC is read (MFE FFn DSCRT8 bit 16).
for n in (1, 2, 3):
    CONTROLS["tacan%d" % n] = dict(panel="O7", kind="rot", caption="TACAN %d MODE" % n,
                                   positions=("OFF", "RCV", "T/R", "GPC"), default="GPC",
                                   contacts={"GPC": [(n, 8, 0x0001)]}, sources="GYUTAC 55")

# R2: MPS propellant dump (OPS 1/6).
CONTROLS.update({
    "mps_dump_seq": dict(panel="R2", kind="t3", caption="MPS PRPLT DUMP\nSEQUENCE",
                         positions=("START", "GPC", "STOP"), default="GPC",
                         contacts={"START": _ff((1, 2), 8, 0x0080), "STOP": _ff((1, 2), 8, 0x0040)}),
    "mps_dump_lh2": dict(panel="R2", kind="t3", caption="BACKUP\nLH2 VLV",
                         positions=("OPEN", "GPC", "CLOSE"), default="GPC",
                         contacts={"OPEN": _ff((3, 4), 8, 0x0080), "CLOSE": _ff((3, 4), 8, 0x0040)}),
})

PANES.update({
    "C3": [("SEPARATION", [["srb_sep_sw", "srb_sep_pb", "et_sep_sw", "et_sep_pb"]]),
           ("MAIN ENGINE", [["me_limit", "me_sd_left", "me_sd_ctr", "me_sd_right"]]),
           ("PLT", [["bodyflap_plt", "ptrim_plt"], ["rtrim_plt", "ytrim_plt"]])],
    "L2": [("CDR", [["bodyflap_cdr", "ptrim_cdr", "entry_mode", "nws"],
                    ["rtrim_cdr", "ytrim_cdr"]])],
    "F2": [("FLIGHT CONTROL", [["pitch_css_cdr", "pitch_auto_cdr"],
                               ["ry_css_cdr", "ry_auto_cdr"]])],
    "F4": [("FLIGHT CONTROL", [["pitch_auto_plt", "pitch_css_plt"],
                               ["ry_auto_plt", "ry_css_plt"]])],
    "F6": [("ABORT", [["abort_mode", "abort_pb"]]),
           ("RCS COMMAND", [["rcs_roll_l", "rcs_roll_r"], ["rcs_yaw_l", "rcs_yaw_r"],
                            ["rcs_pitch_u", "rcs_pitch_d"]]),
           ("DISPLAY SELECT", [["air_data_cdr", "hsi_mode_cdr", "hsi_source_cdr",
                                "hsi_unit_cdr", "rdr_altm_cdr"]])],
    "F8": [("DISPLAY SELECT", [["air_data_plt", "hsi_mode_plt", "hsi_source_plt",
                                "hsi_unit_plt", "rdr_altm_plt"]])],
    "O7": [("TACAN", [["tacan1", "tacan2", "tacan3"]])],
    "R2": [("MPS PROPELLANT DUMP", [["mps_dump_seq", "mps_dump_lh2"]])],
})
check()
