#!/usr/bin/env python3
"""Explain why PASS accepted or refused an OPS request, from a memory snapshot.

    tools/opsdiag.py <snapshot.bin> [--ops N] [--mf {PL,GNC,SM}] [--gpc N]

The snapshot is one written by YAGPC_SNAPSHOT=<t>:<prefix> -- main storage as
big-endian halfwords.

Three things get read out, in the order DM6OPS itself uses them:

  1. The GRT (CZ2V_GRT_TAB / CZ2B_GRT_GPC_SET).  DM6_AMT_GRT_SEARCH finds the
     row whose MF and OPS match the request AND whose memory-configuration
     number equals its own index; DM6_TARGET_RUN_GPC then turns that row's GPC
     set into TARGET_GPC.  This is where an OPS request is silently aimed at a
     GPC that is not the one running: MF PL OPS 9 targets GPC 2 ALONE.

  2. The GPC sets -- CS, RS, and this GPC's own bit -- which give RUN_GPC.

  3. DMZ_LOG, PASS's own record of the verdict, so the reading is checked
     against what the software actually decided rather than believed.

Offsets come from the SDF (modules/sdfpkg over PFS/OI340600/SDFLIB); the
compool #PCZ2COM is at 0x23f4 in the tape's build, confirmed by the GRT GPC
set matching CZ2COMMO's own initialiser halfword for halfword."""

import argparse, io, struct, sys

CZ2 = 0x23f4                     # #PCZ2COM's base in the loaded image
GRT_TAB = 1209                   # CZ2V_GRT_TAB, 10 rows x 6 halfwords
GRT_GPC_SET = 776                # CZ2B_GRT_GPC_SET, 10 halfwords
CZ2V_MC_REQ = 772
CZ2V_REC_OPS, CZ2V_REC_XERR = 1176, 1178
N_MC = 10                        # CZ2V_NBR_MEM_CONFIGS

# CZ2V_GST is the PER-GPC structure and it sits at the compool's own base:
# 5 copies (CZ2V_NBR_GPCS) of 20 halfwords.  Reading GPC 2's common set at the
# offset of GPC 1's is a silent way to get a right-looking wrong answer, so the
# members are named relative to a copy and the copy is selected by GPC number.
GST_STRIDE = 20
GST = {"CURRENT_OPS": 8, "BUS_MGMT_MC": 11, "PROG_OVLY": 14, "MF_OVLY": 15,
       "MC": 16, "TB_ID": 17, "CS": 18, "RS": 19}

MF_NAME = {1: "PL", 2: "GNC", 3: "SM"}
MF_NUM = {v: k for k, v in MF_NAME.items()}

# DM6OPS's own DM6V_ERR_TYPE.  9 is undocumented in the source: it is set
# where the transition-table test fails.
ERR = {0: "NONE", 1: "NO TARGETS IN RUN", 2: "NO TARGET GPCS FROM GRT",
       3: "NOT OVERLAY INITIATOR AND NOT IN GPC MAIN MEMORY",
       4: "MODE RECALL FROM APPLICATION", 5: "MODE TO MODE...MORE ILLEGAL",
       6: "FROM KEYBOARD, NOT REQUESTED TO TARGET GPC/RS",
       7: "FROM APPLICATION, NOT IN GPC MAIN MEMORY",
       8: "OPS TO OPS REQUEST: ILLEGAL TRANSITION",
       9: "TRANSITION-TABLE TEST FAILED"}
TAG = {0xd6cc: "COMBINATION", 0xd6f1: "NON MODE RECALL",
       0xd6f2: "MODE RECALL", 0xd6f3: "MODE TO MODE"}


def load(path):
    b = io.open(path, "rb").read()
    return [struct.unpack(">H", b[i:i + 2])[0] for i in range(0, len(b), 2)]


def gpcs_of(mask):
    """CDMB_RSCS_MSK's layout: GPC n is bit (0x10 >> (n-1))."""
    return [n for n in range(1, 6) if mask & (0x10 >> (n - 1))]


def target_gpc(tset):
    """DM6_TARGET_RUN_GPC: TARGET_GPC$(12 TO 16) = TSET$(1 TO 5) -- the GPC
    set's top five bits become TARGET_GPC's bottom five."""
    return (tset >> 11) & 0x1f


def show_grt(w, ops, mf, gpc):
    base = CZ2 + GRT_TAB
    print("GRT  (CZ2V_GRT_TAB at 0x%04x, CZ2B_GRT_GPC_SET at 0x%04x)"
          % (base, CZ2 + GRT_GPC_SET))
    print("  idx  MC POVL MFOVL  MF  OPS MAXMODE   GPC set  targets")
    hit = None
    for i in range(N_MC):
        e = w[base + 6 * i:base + 6 * i + 6]
        tset = w[CZ2 + GRT_GPC_SET + i]
        usable = (e[0] == i + 1)          # CZ2V_GRT_MC$(GRTS) = GRTS
        note = "" if usable else "   (MC != index: never matches)"
        print("  %3d %3d %4d %5d %3d %4d %6d    %04x    %-12s%s"
              % (i + 1, e[0], e[1], e[2], e[3], e[4], e[5], tset,
                 ",".join("GPC%d" % g for g in gpcs_of(target_gpc(tset))), note))
        if usable and e[3] == mf and e[4] == ops:
            hit = (i + 1, e, tset)
    print()
    if hit is None:
        print("  MF %d (%s) OPS %d: NO usable GRT row -> DM6V_GRT_INDEX stays 0,"
              % (mf, MF_NAME.get(mf, "?"), ops))
        print("  so TSET is read out of bounds and the request fails early.")
        return None
    idx, e, tset = hit
    tg = target_gpc(tset)
    print("  MF %d (%s) OPS %d -> GRT index %d, set %04x, TARGET_GPC=%04x = %s"
          % (mf, MF_NAME.get(mf, "?"), ops, idx, tset, tg,
             ",".join("GPC%d" % g for g in gpcs_of(tg))))
    selfbit = 0x10 >> (gpc - 1)
    if tg & selfbit:
        print("  GPC %d's own bit %04x IS in TARGET_GPC -- this test passes."
              % (gpc, selfbit))
    else:
        print("  GPC %d's own bit %04x is NOT in TARGET_GPC." % (gpc, selfbit))
        print("  RUN_GPC = (... OR CDMB_RSALL) AND TARGET_GPC is then 0, and")
        print("  DM6_TARGET_RUN_GPC sets DM6V_ERR_TYPE = 1, NO TARGETS IN RUN.")
    return tg


def gst(w, gpc, member):
    return w[CZ2 + GST_STRIDE * (gpc - 1) + GST[member]]


def show_sets(w, gpc):
    print("\nGPC SETS  (CZ2V_GST copy %d at 0x%04x)"
          % (gpc, CZ2 + GST_STRIDE * (gpc - 1)))
    print("  CZ2B_CS (common set)     = %04x" % gst(w, gpc, "CS"))
    print("  CZ2B_RS (redundant set)  = %04x" % gst(w, gpc, "RS"))
    print("  CZ2V_CURRENT_OPS[1..3]   = %04x %04x %04x"
          % tuple(w[CZ2 + GST_STRIDE * (gpc - 1) + GST["CURRENT_OPS"]:][:3]))
    print("  this GPC is %d, so CDMB_RSCS_MSK$(%d) = %04x"
          % (gpc, gpc, 0x10 >> (gpc - 1)))

    print("\nMEMORY CONFIGURATION")
    for g in range(1, 6):
        mc = gst(w, g, "MC")
        note = ""
        if g == gpc:
            note = ("   <- this GPC, and it has NO memory configuration"
                    if mc == 0 else "   <- this GPC")
        print("  CZ2V_MC$(%d) = %-3d  PROG_OVLY=%-3d MF_OVLY=%-3d TB_ID=%d%s"
              % (g, mc, gst(w, g, "PROG_OVLY"), gst(w, g, "MF_OVLY"),
                 gst(w, g, "TB_ID"), note))
    print("  CZ2V_MC_REQ  = %04x" % w[CZ2 + CZ2V_MC_REQ])

    print("\nRECONFIGURATION")
    ops, xerr = w[CZ2 + CZ2V_REC_OPS], w[CZ2 + CZ2V_REC_XERR]
    print("  CZ2V_REC_OPS  = %d   %s" % (ops,
          "the reconfiguration was never requested" if ops == 0
          else "an OPS %d reconfiguration was requested" % ops))
    print("  CZ2V_REC_XERR = %d   %s" % (xerr,
          "no error" if xerr == 0 else
          "DM2APP logs this as d2ff %04x and takes its ERROR branch" % xerr))
    if xerr == 1:
        print("     ARCGPC sets 1 in two places -- ARC_OPS_ZERO when"
              " CZ2V_MC$(self) is 0, and")
        print("     ARC_OPS_TRANS when ARC_TRANS_COND = 2.  Which one fired"
              " needs a store watch")
        print("     (YAGPC_WATCHHW on this address), not inference: they mean"
              " different things.")


def show_log(w):
    print("\nDMZ_LOG  (PASS's own verdict)")
    for i, x in enumerate(w):
        if x != 0x0c5c:                  # DMZB_LOG_ALIGNMENT
            continue
        n = w[i - 1]                     # DMZV_SET_NBR
        base = i + 3                     # marker + LAST_ENTRY, then the array
        print("  marker 0x%05x, next slot %d" % (i, n))
        for s in range(max(1, n - 6), n):
            a = base + 2 * (s - 1)
            if a + 1 >= len(w):
                continue
            t, v = w[a], w[a + 1]
            note = ""
            if t in TAG:
                note = "  <- %s, ERR_TYPE=%d (%s)" % (TAG[t], v,
                                                      ERR.get(v, "?"))
            elif (t & 0xff00) == 0xd600:
                note = "  <- OPS %d mode %d" % (t & 0xff, v)
            print("    slot %3d 0x%05x: %04x %04x%s" % (s, a, t, v, note))
        return
    print("  no DMZB_LOG_ALIGNMENT marker found")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("snapshot")
    ap.add_argument("--ops", type=int, default=9, help="requested OPS (default 9)")
    ap.add_argument("--mf", default="PL", choices=sorted(MF_NUM),
                    help="requesting major function (default PL)")
    ap.add_argument("--gpc", type=int, default=1, help="which GPC is running (default 1)")
    a = ap.parse_args()
    w = load(a.snapshot)
    show_grt(w, a.ops, MF_NUM[a.mf], a.gpc)
    show_sets(w, a.gpc)
    show_log(w)


if __name__ == "__main__":
    main()
