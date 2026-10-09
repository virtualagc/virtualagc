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
               "tb"          a talkback: positions are its two states (a
                             word, GRAY or BP), shown as the first while
                             the switch named by 'follows' is in its first
                             position and as the second otherwise
               "cb"          a circuit breaker, IN or OUT
               "blank"       an empty place in a grid of controls
               "ann"         an annunciator: a flat light with its legend,
                             lit in its 'color' (red or amber) when any of
                             its 'lamps' is set
    caption    printed above it ("\\n" for two lines)
    positions  for t2/t3/rot: the legends, as printed
    default    for t2/t3/rot: where it starts
    legend     for pb/pbi: what is printed on the button ("\\n" for two)
    contacts   which crew-contact bits are closed: for t2/t3/rot a dict
               {position: [(unit, dscrt, mask), ...]}; for pb/pbi a list
               [(unit, dscrt, mask), ...], closed while the button is held.
               unit 1-4 is FF1-4, 5-8 FA1-4 (yaGPC2 mdmdev.c's crew units);
               dscrt is the FF DSCRT word 1-13 (FA: 1-3), mask its bit(s).
    lamps      for pbi / lamp: [(unit, card, channel, mask), ...] -- lit when
               any of those DOH output bits is set
    halves     for a split-legend lamp instead of lamps: [(legend, lamps
               [, colour]), ...], each half lit on its own (in its colour,
               else white); split "h" puts them side by side, "v" one over
               the other
    hold_ms    for pb/pbi: how long a scripted 'press' holds it (500)
    spring     for switches: positions that spring back to the default when
               let go -- held only while the mouse is down, and for hold_ms
               when a script moves it there
    while_held for switches: the key of a pushbutton; the contacts close only
               while that button is held too (ABORT MODE with ABORT)
    guarded    for pb: drawn with a guard (appearance only)
    hardwired  for pb: a bit of the vehicle's HARDWIRED word (for a switch, a
               dict {position: bits}, set while it is in that position) -- functions no
               computer commands or reads (landing gear, drag chute), sent
               to yaGPC2 (mdmdev.c crew type 8, vehdyn.c vehdyn_hardwired)
               while the button is held; the vehicle latches them
    sources    where this came from (flight source, SCOM page), as text

A PANE is a titled group of controls in rows: PANES[panel] is a list of
(title, [[key, key, ...], [key, ...]]), drawn in that order in the panel's
window after its older, hand-drawn panes.  A row may instead be a string: a
legend across the pane over the rows that follow, as a panel's own group
legends are printed (O6's STAR TRACKER DOOR CONTROL over SYS 1 and SYS 2).
"""

CONTROLS = {}
PANES = {}

KINDS = ("t2", "t3", "h3", "rot", "pb", "pbi", "lamp", "tb", "cb", "blank", "ann")
FF_UNITS = (1, 2, 3, 4)
# Lamps lit from the VEHICLE's own state rather than a PASS output word: the
# hardwired landing gear and drag chute indications (yaGPC2 mdmdev.c
# veh_status_publish, crew type 10).  panelO6 files those records as unit 0.
VEH_UNIT = 0
FA_UNITS = (5, 6, 7, 8)


def check():
    """Raise ValueError naming the first malformed entry, if any."""
    for key, c in CONTROLS.items():
        where = "panelcontrols %s" % key
        if c.get("kind") not in KINDS:
            raise ValueError("%s: kind %r" % (where, c.get("kind")))
        if not c.get("panel"):
            raise ValueError("%s: no panel" % where)
        if c["kind"] in ("tb", "blank"):
            continue
        if c["kind"] == "ann":
            if c.get("color") not in ("red", "amber", "white", "green", "blue"):
                raise ValueError("%s: color %r" % (where, c.get("color")))
        if c["kind"] in ("t2", "t3", "h3", "rot", "cb"):
            pos = c.get("positions") or ()
            need = {"t2": 2, "t3": 3, "h3": 3, "cb": 2}.get(c["kind"])
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
            lamps = list(c.get("lamps") or ())
            for h in c.get("halves") or ():
                lamps += h[1]
            for lamp in lamps:
                if len(lamp) != 4 or (lamp[0] not in FF_UNITS and lamp[0] != VEH_UNIT):
                    raise ValueError("%s: lamp %r" % (where, lamp))
    for panel, panes in PANES.items():
        for title, rows, *_opts in panes:
            for row in rows:
                if isinstance(row, str):
                    continue
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
    return CONTROLS[key]["kind"] in ("t2", "t3", "h3", "rot", "cb")


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
# SPLIT-LEGEND LIGHTS, as drawn (SCOM 2.7 "RCS COMMAND Lights on Panel F6"):
# ROLL and YAW split left | right, PITCH split up over down; white.
for key, cap, split, halves in (
        ("rcs_roll", "ROLL", "h", (("L", 0x0100), ("R", 0x0080))),
        ("rcs_yaw", "YAW", "h", (("L", 0x0040), ("R", 0x0020))),
        ("rcs_pitch", "PITCH", "v", (("U", 0x0010), ("D", 0x0008)))):
    CONTROLS[key] = dict(panel="F6", kind="lamp", caption=cap, split=split,
                         halves=[(leg, [(1, 2, 1, m), (3, 2, 1, m)]) for leg, m in halves],
                         sources="GFBRCS 1515-1535; lights, though they look like rockers")

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
           ("RCS COMMAND", [["rcs_roll", "rcs_pitch"], ["rcs_yaw"]]),
           ("DISPLAY SELECT", [["air_data_cdr", "hsi_mode_cdr", "hsi_source_cdr",
                                "hsi_unit_cdr", "rdr_altm_cdr"]])],
    "F8": [("DISPLAY SELECT", [["air_data_plt", "hsi_mode_plt", "hsi_source_plt",
                                "hsi_unit_plt", "rdr_altm_plt"]])],
    "O7": [("TACAN", [["tacan1", "tacan2", "tacan3"]])],
    "R2": [("MPS PROPELLANT DUMP", [["mps_dump_seq", "mps_dump_lh2"]])],
})

# THE LANDING GEAR AND THE DRAG CHUTE: hardwired, with no GPC contacts at all
# (PASS commands them only in remote-control mode, GGAAUT.hal 287-312, and
# learns of the gear through its uplock and WOW discretes).  ARM, then DN /
# DPY; the vehicle latches each.  The bits are vehdyn.c's HW_*.
#
# THEIR LIGHTS are the vehicle's, not the button's (landing-indicators-
# findings.md, SCOM OI-28 2.14-10/11, the Entry Checklist's "ARM lt on", "DN lt
# on", "All lts on", "JETT1, JETT2 lt on"): each lights when its relay
# latches and stays lit; the gear's DN light shows the command, not where the
# gear is -- the LEFT/NOSE/RIGHT talkbacks show that, from the proximity
# switches (UP uplocked, DN down and locked, barberpole between).  Both seats
# have a set: the gear on F6 and F8; the drag chute's ARM and DPY on F2
# (commander) and F3 right (pilot), its JETT on F3 left (commander) and F4
# (pilot); the chute's legends are split, ARM 1/ARM 2 and so on.  The lights
# come from yaGPC2 as unit 0 (mdmdev.c veh_status_publish, vehdyn.c
# vehdyn_landing_status): card 0 channel 0 the relays, channel 1 the gear.
_VEH_RELAY, _VEH_GEAR = (VEH_UNIT, 0, 0), (VEH_UNIT, 0, 1)


def _veh(chan, mask):
    return [chan + (mask,)]


def _chute(panel, leg, hw, mask):
    return dict(panel=panel, kind="pbi", caption="", legend=leg, guarded=True, contacts=[],
                hardwired=hw, split="v",
                halves=[(leg + " 1", _veh(_VEH_RELAY, mask), "white"),
                        (leg + " 2", _veh(_VEH_RELAY, mask), "white")],
                sources="SCOM OI-28 Part 4 PDF 108 (split legends); ECL 'All lts on'")


for _sfx, _pan in (("", "F6"), ("_p", "F8")):
    CONTROLS.update({
        "gear_arm" + _sfx: dict(panel=_pan, kind="pbi", caption="", legend="ARM", guarded=True,
                                contacts=[], hardwired=0x8000, color="amber",
                                lamps=_veh(_VEH_RELAY, 0x8000),
                                sources="SCOM OI-28 2.14-10: yellow, lit when ARM latches"),
        "gear_dn" + _sfx: dict(panel=_pan, kind="pbi", caption="", legend="DN", guarded=True,
                               contacts=[], hardwired=0x4000, color="green",
                               lamps=_veh(_VEH_RELAY, 0x4000),
                               sources="SCOM OI-28 2.14-11: green, lit when DN latches"),
    })
    for _g, _up, _dn in (("left", 0x8000, 0x4000), ("nose", 0x2000, 0x1000),
                         ("right", 0x0800, 0x0400)):
        CONTROLS["gear_tb_%s%s" % (_g, _sfx)] = dict(
            panel=_pan, kind="tb", caption=_g.upper(), positions=("UP", "DN", "BP"),
            states=[("UP", _veh(_VEH_GEAR, _up)), ("DN", _veh(_VEH_GEAR, _dn))],
            sources="SCOM OI-28 2.14: gear proximity switches; barberpole in transit")
CONTROLS.update({
    "chute_arm": _chute("F2", "ARM", 0x2000, 0x2000),
    "chute_dpy": _chute("F2", "DPY", 0x1000, 0x1000),
    "chute_jett": _chute("F3", "JETT", 0x0800, 0x0800),
    "chute_arm_p": _chute("F3", "ARM", 0x2000, 0x2000),
    "chute_dpy_p": _chute("F3", "DPY", 0x1000, 0x1000),
    "chute_jett_p": _chute("F4", "JETT", 0x0800, 0x0800),
    # The toe brakes on the rudder pedals, as a simulator's latch (no pedals
    # here): ON holds about 8 ft/s^2 on the main gear until OFF.  No lamps:
    # the real brakes had none.
    "brakes_on": dict(panel="F6", kind="pb", caption="", legend="ON",
                      contacts=[], hardwired=0x0400,
                      sources="simulator: the pedals' toe brakes, latched"),
    "brakes_off": dict(panel="F6", kind="pb", caption="", legend="OFF",
                       contacts=[], hardwired=0x0200),
})
# THE AIR DATA PROBES (panel C3): each switch drives its probe's motors --
# STOW in, DEPLOY out (and heat), ENABLE holds -- and PASS reads only the
# probes' limit switches (FF DSCRT8 0x0020 deployed / 0x0010 stowed).
CONTROLS.update({
    "adp_l": dict(panel="C3", kind="t3", caption="AIR DATA PROBE\nLEFT",
                  positions=("STOW", "ENABLE", "DEPLOY"), default="STOW", contacts={},
                  hardwired={"DEPLOY": 0x0100, "STOW": 0x0040}),
    "adp_r": dict(panel="C3", kind="t3", caption="AIR DATA PROBE\nRIGHT",
                  positions=("STOW", "ENABLE", "DEPLOY"), default="STOW", contacts={},
                  hardwired={"DEPLOY": 0x0080, "STOW": 0x0020}),
})
PANES["C3"].append(("AIR DATA PROBE", [["adp_l", "adp_r"]]))
PANES["F6"].append(("LANDING GEAR", [["gear_arm", "gear_dn"],
                                     ["gear_tb_left", "gear_tb_nose", "gear_tb_right"]]))
PANES["F8"].append(("LANDING GEAR", [["gear_arm_p", "gear_dn_p"],
                                     ["gear_tb_left_p", "gear_tb_nose_p", "gear_tb_right_p"]]))
PANES["F6"].append(("BRAKES", [["brakes_on", "brakes_off"]]))
PANES["F2"].append(("DRAG CHUTE", [["chute_arm", "chute_dpy"]]))
CONTROLS["f3_chute_gap"] = dict(panel="F3", kind="blank")
PANES.setdefault("F3", []).append(("DRAG CHUTE", [["chute_jett", "f3_chute_gap", "chute_arm_p",
                                                   "chute_dpy_p"]]))
PANES["F4"].append(("DRAG CHUTE", [["chute_jett_p"]]))
check()


# ---------------------------------------------------------------------------
# SYSTEMS MANAGEMENT, OPS 2 (and 4): the switches the SM software reads, from
# the 2026-10-02 S2 survey.  SHOWN BUT NOT YET CONNECTED: SM reads these
# through the PCMMU (orbiter instrumentation MDMs OF1-4/OA1-3, payload MDMs
# PF1/PF2) and the RMS through its MCIU, none of which yaGPC2 emulates yet --
# so they have no contacts here ('via' says where they will come from).  The
# owner's call (2026-10-02): an OPS's panels appear even before every
# control on them works.

def _sm(key, panel, kind, caption, positions, default, via, **kw):
    CONTROLS[key] = dict(panel=panel, kind=kind, caption=caption, positions=positions,
                         default=default, contacts={}, via=via, **kw)


_PCM = "PCMMU (OF/OA MDM) -- not yet emulated"
_MCIU = "RMS MCIU -- not yet emulated"

_sm("plbd", "R13L", "t3", "PAYLOAD BAY\nDOOR", ("OPEN", "STOP", "CLOSE"), "STOP", _PCM,
    sources="four contacts per position, voted 2-of-4 (SSBPLBAY 224-237)")
_sm("fc_purge_seq", "R11U", "t2", "FUEL CELL\nGPC PURGE SEQ", ("START", "OFF"), "OFF", _PCM,
    spring=("START",), sources="V72K6050Y; SSCFUELC 118-123")
_sm("fc_purge_htr", "R11U", "t3", "PURGE\nHEATER", ("GPC", "OFF", "ON"), "GPC", _PCM)
for n in (1, 2, 3):
    _sm("fc_purge_vlv%d" % n, "R11U", "t3", "PURGE\nVALVE %d" % n,
        ("OPEN", "GPC", "CLOSE"), "GPC", _PCM)
for n in (1, 2, 3):
    _sm("hyd_circ_pump%d" % n, "R2", "t3", "HYD CIRC\nPUMP %d" % n, ("ON", "GPC", "OFF"),
        "GPC", _PCM, sources="SSTHYDFL 281,423")
    _sm("boiler_cntlr%d" % n, "R2", "t3", "BOILER\nCNTLR/HTR %d" % n, ("A", "OFF", "B"),
        "OFF", _PCM, sources="SSHHYD 108-121")
_sm("freon_isol", "L1", "t2", "FREON ISOLATION\nMODE", ("AUTO", "MAN"), "AUTO", _PCM,
    sources="V63S1200E; panel L1 per the source, L2 per SCOM text")
_sm("sband_pm_ant", "C3", "rot", "S-BAND PM\nANTENNA",
    ("GPC", "LL F", "LL A", "UL F", "UL A", "UR F", "UR A", "LR F", "LR A"), "GPC", _PCM,
    sources="SCOM 2.4-5; only GPC is read (SSMANTMG 982); order of the eight unverified")
_sm("sband_fm_ant", "A1R", "t3", "S-BAND FM\nANTENNA", ("UPPER", "GPC", "LOWER"), "GPC", _PCM,
    sources="SSMANTMG 984-986")
# A1U KU-BAND, the radar's side (RENDEZVOUS_PLAN.md Stage 3; AFT FLT
# STATION CONFIG [4A]: "KU PWR STBY, sel MAN SLEW, MODE RDR PASSIVE, RADAR
# OUTPUT HI, CNTL PNL").  The Ku signal processor and the SM computer they
# really reach are not here: panelO6 sends POWER, MODE, STEERING MODE and
# RADAR OUTPUT as one word ('ku' below; op 4 VALUE, type 9, to FF3) to
# yaGPC2's kuradar.c, which stands in for them.  CONTROL is shown only.
_KU = "Ku-band signal processor -- yaGPC2 kuradar.c (one word to FF3)"
_sm("ku_steering", "A1U", "rot", "KU-BAND\nSTEERING MODE",
    ("GPC", "GPC DESIG", "AUTO TRACK", "MAN SLEW"), "GPC", _KU,
    ku={"GPC": 0x0000, "GPC DESIG": 0x0004, "AUTO TRACK": 0x0008, "MAN SLEW": 0x000C},
    sources="SCOM 2.4-19 (panel A1U); SM reads only GPC ACQ (SSMANTMG 927)")
_sm("ku_power", "A1U", "t3", "KU-BAND\nPOWER", ("ON", "STBY", "OFF"), "OFF", _KU,
    ku={"ON": 0x8000}, sources="SCOM 2.4-19; [4A] KU PWR STBY, the KU OPS cue card ON")
_sm("ku_mode", "A1U", "rot", "KU-BAND\nMODE", ("COMM", "RDR PASSIVE", "RDR COOP"), "COMM", _KU,
    ku={"RDR PASSIVE": 0x0001, "RDR COOP": 0x0002}, sources="SCOM 2.4-19; [4A] MODE RDR PASSIVE")
_sm("ku_radar_output", "A1U", "t3", "RADAR\nOUTPUT", ("HIGH", "MED", "LOW"), "HIGH", _KU,
    ku={"HIGH": 0x0010}, sources="[4A] RADAR OUTPUT HI; LOW at about 700 ft")
_sm("ku_control", "A1U", "t2", "KU-BAND\nCONTROL", ("PNL", "CMD"), "PNL", _KU,
    sources="[4A] CNTL PNL, then CMD; not modelled (no SM computer)")
_sm("rms_mode", "A8U", "rot", "MODE",
    ("TEST", "AUTO 1", "AUTO 2", "AUTO 3", "AUTO 4", "OPR CMD", "ORB UNL", "END EFF",
     "ORB LD", "PL", "SINGLE", "DIRECT"), "SINGLE", _MCIU, sources="V72K2970-2981J")
CONTROLS["rms_mode_enter"] = dict(panel="A8U", kind="pb", caption="MODE", legend="ENTER",
                                  contacts=[], via=_MCIU)
_sm("rms_parameter", "A8U", "rot", "PARAMETER",
    ("TEST", "POSITION", "ATTITUDE", "JOINT ANGLE", "VELOCITY", "RATE",
     "PORT TEMP", "STBD TEMP"), "POSITION", _MCIU)
_sm("rms_joint", "A8U", "rot", "JOINT",
    ("SHOULDER YAW", "SHOULDER PITCH", "ELBOW PITCH", "WRIST PITCH", "WRIST YAW",
     "WRIST ROLL", "EE TEMP", "CRIT TEMP"), "SHOULDER YAW", _MCIU)
_sm("rms_brakes", "A8U", "t2", "BRAKES", ("ON", "OFF"), "ON", _MCIU)
_sm("rms_drive", "A8U", "t3", "SINGLE/DIRECT\nDRIVE", ("+", "OFF", "-"), "OFF", _MCIU,
    spring=("+", "-"))
_sm("rms_auto_seq", "A8U", "t3", "AUTO SEQ", ("PROCEED", "OFF", "STOP"), "OFF", _MCIU,
    spring=("PROCEED", "STOP"))
_sm("rms_rate", "A8U", "t2", "RATE", ("VERNIER", "COARSE"), "COARSE", _MCIU)
_sm("rms_rate_hold", "A8U", "t2", "RATE HOLD", ("ON", "OFF"), "OFF", _MCIU)
_sm("rms_ee_mode", "A8U", "t3", "END EFF\nMODE", ("AUTO", "OFF", "MAN"), "OFF", _MCIU)
_sm("rms_ee_man", "A8U", "t3", "END EFF\nMAN CONTR", ("RIGID", "OFF", "DERIGID"), "OFF", _MCIU,
    spring=("RIGID", "DERIGID"))
_sm("rms_safing", "A8U", "t3", "SAFING", ("SAFE", "AUTO", "CANCEL"), "AUTO", _MCIU,
    sources="read but used by no S2 code")
_sm("rms_shoulder_brace", "A8U", "t3", "SHOULDER BRACE\nRELEASE", ("PORT", "OFF", "STBD"),
    "OFF", _MCIU, sources="read but used by no S2 code")
CONTROLS["rms_master_alarm"] = dict(panel="A8U", kind="pb", caption="MASTER", legend="ALARM",
                                    contacts=[], via=_MCIU)
_sm("rms_select", "A8L", "t3", "RMS SELECT", ("PORT", "OFF", "STBD"), "OFF", _MCIU,
    sources="V54X2025J/2026J")
_sm("rms_power", "A8L", "t3", "RMS POWER", ("PRIMARY", "OFF", "BACKUP"), "OFF", _MCIU,
    sources="display only (SPEC 94)")

# O6 STAR TRACKER (TD0216 Fig 3-4, pp. 3-1 to 3-6; SCOM 2.13-11; JSC-12770
# Vol 6 Table B-XI).  All hardwired: POWER feeds a tracker (CB on O14/O15),
# DOOR CONTROL SYS 1 / SYS 2 drive the doors' two motors through the FMCAs,
# and the DOOR POSITION talkbacks show the doors' limit switches -- OP, CL,
# barberpole between.  The computers neither command nor read them, apart
# from the -Y door's OP/CL contacts (FF1 / FF3 DSCRT11 bits 14 / 13,
# CGBB_STAR_Y_DOOR_OP/CL, downlist only), which panelO6 drives from its
# door model, as it does the trackers' power and doors in yaGPC2 (startrk.c).
for _sd in ("y", "z"):
    CONTROLS["strk_pwr_" + _sd] = dict(
        panel="O6", kind="t2", caption="-%s" % _sd.upper(), positions=("ON", "OFF"),
        default="ON", contacts={},
        sources="TD0216 Fig 3-4 (S4/S5); JSC-12770 Vol 6 B-34; hardwired to the tracker")
    CONTROLS["strk_door_tb_" + _sd] = dict(
        panel="O6", kind="tb", caption="-%s" % _sd.upper(), positions=("OP", "CL"),
        door=_sd, sources="TD0216 Fig 3-4 (DS1/DS2); JSC-12770 Vol 6 B-35")
for _n in (1, 2):
    CONTROLS["strk_door_sys%d" % _n] = dict(
        panel="O6", kind="t3", caption="SYS %d" % _n,
        positions=("OPEN", "OFF", "CLOSE"), default="OFF", contacts={},
        sources="TD0216 Fig 3-4 (S2/S3); JSC-12770 Vol 6 B-34: both doors' system-%d motors"
                % _n)
PANES["O6"] = [("STAR TRACKER", ["DOOR POSITION", ["strk_door_tb_y", "strk_door_tb_z"],
                                 "DOOR CONTROL", ["strk_door_sys1", "strk_door_sys2"],
                                 "POWER", ["strk_pwr_y", "strk_pwr_z"]])]

PANES["R13L"] = [("PAYLOAD BAY", [["plbd"]])]
PANES["R11U"] = [("FUEL CELL PURGE", [["fc_purge_seq", "fc_purge_htr"],
                                      ["fc_purge_vlv1", "fc_purge_vlv2", "fc_purge_vlv3"]])]
PANES["R2"].append(("HYDRAULICS", [["hyd_circ_pump1", "hyd_circ_pump2", "hyd_circ_pump3"],
                                   ["boiler_cntlr1", "boiler_cntlr2", "boiler_cntlr3"]]))
PANES["L1"] = [("FREON", [["freon_isol"]])]
PANES["C3"].append(("S-BAND PM", [["sband_pm_ant"]]))
PANES["A1R"] = [("S-BAND FM", [["sband_fm_ant"]])]
PANES["A1U"] = [("KU-BAND", [["ku_power", "ku_mode", "ku_steering"], ["ku_radar_output", "ku_control"]])]
PANES["A8U"] = [("RMS", [["rms_mode", "rms_mode_enter", "rms_parameter", "rms_joint"],
                         ["rms_brakes", "rms_drive", "rms_auto_seq", "rms_rate", "rms_rate_hold"],
                         ["rms_ee_mode", "rms_ee_man", "rms_safing", "rms_shoulder_brace",
                          "rms_master_alarm"]])]
PANES["A8L"] = [("RMS", [["rms_select", "rms_power"]])]
check()



# ---------------------------------------------------------------------------
# THE PAYLOAD STANDARD SWITCH PANELS, SSP 1-3 on L12U, L12L and L11U (owner,
# 2026-10-02).  One grid on every flight -- switch places S1-S24, talkback
# places DS1-DS24 above them, circuit breakers CB1-CB4 -- and what is fitted
# where, and called what, is the flight's (STS-109 Payload Systems Data and
# Malfunction Procedures, section 10, shows three).  Without a names file each
# is the bare grid: a two-position toggle at every switch place, numbered,
# and the four breakers.  With one (panelO6.py --ssp FILE) each place is what
# the file says.  They are wired to the payload, not to PASS: nothing here
# reaches a GPC, and a talkback can only follow a switch ('follows'), as the
# payload would answer it.
#
# The names file, one place per line ('#' to the end of a line is ignored):
#     PANEL  PLACE  KIND  | CAPTION | POSITIONS | FOLLOWS
# PANEL is L12U, L12L or L11U; PLACE is S1-S24, DS1-DS24, CB1-CB4 or Q1-Q4
# (the quadrants: Q1 upper left, Q2 upper right, Q3 lower left, Q4 lower
# right, whose CAPTION is their title).  KIND is t2 or t3 (a toggle), t3m (a
# three-position toggle whose ends spring back to the middle), tb (a
# talkback), cb (a breaker), none (an empty place) or title (for Q1-Q4).
# CAPTION may use \n for a new line; POSITIONS are separated by / (top
# first; for tb the two states, e.g. UP/BP or GRAY/BP); FOLLOWS is the
# switch place a talkback follows.

SSP_PANELS = ("L12U", "L12L", "L11U")
SSP_VIA = "payload (flight-specific) -- not wired to PASS"
_SSP_QUADS = (("Q1", [1, 2, 3, 4, 5, 6, 7], ()),
              ("Q2", [13, 14, 15, 16, 17, 18, 19], ()),
              ("Q3", [8, 9, 10, 11, 12], (2, 1)),
              ("Q4", [20, 21, 22, 23, 24], (4, 3)))


def _ssp_key(panel, place):
    return "%s_%s" % (panel.lower(), place.lower())


def load_ssp(path=None):
    """The three SSPs, bare or from a names file; replaces any loaded before.
    Returns the number of places the file set."""
    for k in [k for k, c in CONTROLS.items() if c.get("ssp")]:
        del CONTROLS[k]
    spec = {}
    titles = {}
    n = 0
    if path:
        with open(path) as fh:
            for lineno, raw in enumerate(fh, 1):
                line = raw.split("#", 1)[0].strip()
                if not line:
                    continue
                head, *fields = [f.strip() for f in line.split("|")]
                words = head.split()
                if len(words) != 3:
                    raise ValueError("%s:%d: expected 'PANEL PLACE KIND | ...'"
                                     % (path, lineno))
                panel, place, kind = words[0].upper(), words[1].upper(), words[2].lower()
                if panel not in SSP_PANELS:
                    raise ValueError("%s:%d: panel %r is not one of %s"
                                     % (path, lineno, panel, ", ".join(SSP_PANELS)))
                fields += [""] * (3 - len(fields))
                if kind == "title":
                    titles[(panel, place)] = fields[0]
                else:
                    spec[(panel, place)] = (kind, fields[0].replace("\\n", "\n"),
                                            [p.strip() for p in fields[1].split("/") if p.strip()],
                                            fields[2].upper())
                n += 1
    for panel in SSP_PANELS:
        panes = []
        for q, places, cbs in _SSP_QUADS:
            tb_row, sw_row = [], []
            for cb_top, cb_bot in ([cbs] if cbs else []):
                tb_row.append(_ssp_place(panel, "CB%d" % cb_top, spec, "cb"))
                sw_row.append(_ssp_place(panel, "CB%d" % cb_bot, spec, "cb"))
            for i in places:
                tb_row.append(_ssp_place(panel, "DS%d" % i, spec, "none"))
                sw_row.append(_ssp_place(panel, "S%d" % i, spec, "t2"))
            panes.append((titles.get((panel, q), ""), [tb_row, sw_row], {"grid": True}))
        PANES[panel] = panes
    check()
    return n


def _ssp_place(panel, place, spec, default):
    key = _ssp_key(panel, place)
    named = (panel, place) in spec
    kind, caption, positions, follows = spec.get((panel, place), (default, "", [], ""))
    c = dict(panel=panel, ssp=True, via=SSP_VIA, caption=caption, contacts={})
    if kind == "none":
        c.update(kind="blank")
    elif kind in ("t2", "t3", "t3m"):
        legends = tuple(positions) or (("ON", "OFF") if kind == "t2" else ("ON", "-", "OFF"))
        # The same legend at both ends (STS-109's ON/OFF/ON): printed as it
        # is, but the positions are named apart -- "ON 1", "OFF", "ON 3" --
        # so that a script and a click can tell them apart.
        pos = tuple(p if legends.count(p) == 1 else "%s %d" % (p, i + 1)
                    for i, p in enumerate(legends))
        if pos != legends:
            c["legends"] = legends
        c.update(kind="t3" if kind == "t3m" else kind, positions=pos,
                 default=pos[1] if len(pos) == 3 else pos[-1],
                 caption=caption if named else place)     # the bare grid is numbered
        if kind == "t3m":
            c["spring"] = (pos[0], pos[-1])
    elif kind == "tb":
        c.update(kind="tb", positions=tuple(positions) or ("GRAY", "BP"),
                 follows=_ssp_key(panel, follows) if follows else None)
    elif kind == "cb":
        c.update(kind="cb", positions=("IN", "OUT"), default="IN",
                 caption=caption if named else place)
    else:
        raise ValueError("SSP %s %s: kind %r" % (panel, place, kind))
    CONTROLS[key] = c
    return key


load_ssp()



# ---------------------------------------------------------------------------
# F7, CAUTION AND WARNING (owner, 2026-10-02).  The annunciator matrix, 8 rows
# of 5 left of CRT 3, from SCOM 2.2-20..22 and Appendix A-5; colours as the
# text gives them where the drawings disagree (FREON LOOP red; RIGHT/AFT RHC
# red, FCS SATURATION amber).  PASS LIGHTS SIXTEEN of them: the fourteen
# GNC class-2 lights, as FF DOL card 5 channel 1 set/reset words -- all on
# FF3 but LEFT RCS on FF1 (DGNLIGHT 55-77, 139-171; on a class-2 message
# until MSG RESET, in configurations 1, 2, 3 and 8) -- and BACKUP C/W ALARM,
# FF3/FF4 DOH card 10 ch 2 bit 4 (DLALIGHT).  The other 24 are the C&W
# unit's own sensor channels, which nothing here models: greyed.

_CW = "C&W unit sensor channel -- not simulated"
_F7 = (
    (("O2 PRESS", "amber"), ("H2 PRESS", "amber"), ("FUEL CELL\nREAC", "red"),
     ("FUEL CELL\nSTACK TEMP", "amber"), ("FUEL CELL\nPUMP", "amber")),
    (("CABIN ATM", "red"), ("O2 HEATER\nTEMP", "amber"), ("MAIN BUS\nUNDERVOLT", "red"),
     ("AC\nVOLTAGE", "amber"), ("AC\nOVERLOAD", "amber")),
    (("FREON\nLOOP", "red"), ("AV BAY/\nCABIN AIR", "amber"), ("IMU", "amber", 3, 0x0200),
     ("FWD RCS", "red", 3, 0x0008), ("RCS JET", "amber", 3, 0x8000)),
    (("H2O LOOP", "amber"), ("RGA/ACCEL", "amber", 3, 0x0020), ("AIR DATA", "red", 3, 0x0040),
     ("LEFT RCS", "red", 1, 0x0010), ("RIGHT RCS", "red", 3, 0x0010)),
    (("", "amber"), ("LEFT RHC", "red", 3, 0x0080), ("RIGHT/AFT\nRHC", "red", 3, 0x0100),
     ("LEFT OMS", "red", 3, 0x2000), ("RIGHT OMS", "red", 3, 0x1000)),
    (("PAYLOAD\nWARNING", "red"), ("GPC", "amber"), ("FCS\nSATURATION", "amber", 3, 0x0400),
     ("OMS KIT", "amber"), ("OMS TVC", "red", 3, 0x4000)),
    (("PAYLOAD\nCAUTION", "amber"), ("PRIMARY C/W", "amber"), ("FCS\nCHANNEL", "amber", 3, 0x0800),
     ("MPS", "red"), ("", "amber")),
    (("BACKUP C/W\nALARM", "red", None, None), ("APU TEMP", "amber"), ("APU\nOVERSPEED", "amber"),
     ("APU\nUNDERSPEED", "amber"), ("HYD PRESS", "amber")),
)
_rows = []
for r, row in enumerate(_F7):
    keys = []
    for col, cell in enumerate(row):
        legend, colour = cell[0], cell[1]
        key = "cw_r%dc%d" % (r + 1, col + 1)
        c = dict(panel="F7", kind="ann", caption="", legend=legend, color=colour, contacts=[])
        if legend.startswith("BACKUP"):
            c["lamps"] = [(3, 10, 2, 0x1000), (4, 10, 2, 0x1000)]
            c["sources"] = "DLALIGHT 89-90, 142-167 (signal A, FF3/FF4)"
        elif len(cell) > 2:
            c["lamps"] = [(cell[2], 5, 1, cell[3])]
            c["sources"] = "DGNLIGHT; class-2 GNC caution"
        else:
            c["via"] = _CW
        CONTROLS[key] = c
        keys.append(key)
    _rows.append(keys)

# MAIN ENGINE STATUS: CTR raised between LEFT and RIGHT; each a split light,
# red over amber, on FF (engine number): red DOH card 10 ch 1 bit 1, amber
# card 2 ch 1 bit 1 (GSPMPS 42-67, 145-154; OPS 1/6).  Engines 1-3 = CTR,
# LEFT, RIGHT by the standard numbering.  And SM ALERT, blue: DOH card 10
# ch 2 bit 6 on FF1-4 (DLALIGHT) -- in SM configurations it goes by the PF
# MDMs instead, which are not captured.
for key, cap, ff in (("mes_left", "LEFT", 2), ("mes_ctr", "CTR", 1), ("mes_right", "RIGHT", 3)):
    CONTROLS[key] = dict(panel="F7", kind="lamp", caption=cap, split="v",
                         halves=[("", [(ff, 10, 1, 0x8000)], "red"),
                                 ("", [(ff, 2, 1, 0x8000)], "amber")],
                         sources="GSPMPS 42-67, 145-154")
CONTROLS["sm_alert"] = dict(panel="F7", kind="ann", caption="", legend="SM\nALERT",
                            color="blue", contacts=[],
                            lamps=[(u, 10, 2, 0x0400) for u in (1, 2, 3, 4)],
                            sources="DLALIGHT; PF MDMs in SM configurations (not captured)")
PANES["F7"] = [("CAUTION / WARNING", _rows, {"grid": True}),
               ("MAIN ENGINE STATUS", [["mes_left", "mes_ctr", "mes_right"], ["sm_alert"]])]
check()
