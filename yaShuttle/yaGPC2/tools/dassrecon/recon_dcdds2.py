#!/usr/bin/env python3
"""Rebuild OI340700's SM downlist collector (DCDDS2 and its DCD124xx/DCD126xx
members) from #CDCDDS2 in the DASS SM2 dump, and verify it.

    recon_dcdds2.py            verify DCDDS2 as PFS holds it
    recon_dcdds2.py --write    rebuild the members and DCDDS2's frame-length
                               constants from the dump IN THE SCRATCH TREE,
                               and compare; PFS 24af1848 holds this result
                               (DCD12401, DCD12601, DCDDS2), with provenance
                               notes added when it was written

How: every member statement is decompiled from the dump's annotated
disassembly (dcdflt.py: kind, include SRN and line, source address,
destination slot, count) and aligned with OI340600's (dcdgen.py); flight
statements OI340600 lacks are written from the dump, and any statement whose
compiled source address differs from the flight's (semcmp.py compares raw
relocated addresses, not names) gets its CSAS_INB_ENTRY subscript renumbered
from the flight's address, until every statement matches.  PFS 24af1848 is
the result.
"""
import re, os, sys, json, shutil, subprocess
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
from paths import PFS, TREE, MAFGEN
import dcdflt, dcdgen, semcmp
PR = os.path.expanduser("~/git/virtualagc/yaShuttle/Source Code/PASS.REL32V0")
def install(members):
    for n, c in members.items(): dcdgen.write_member(n, c, "%s/INCL80/%s.hal" % (TREE, n))
    subprocess.run(["bash", "-c", 'cd "%s" && PATH="%s:$PATH" prepareINCLIB --clear --include=INCL80' % (TREE, PR)], capture_output=True)
def listing_compile():
    env = dict(os.environ); subprocess.run([H + "/hc.sh", "DCDDS2"], capture_output=True, env=env)
def compare():
    r1 = subprocess.run(["python3", H + "/objcmp.py", TREE + "/objects/DCDDS2.obj", "#CDCDDS2", "S2", "--show", "3"], capture_output=True, text=True).stdout.strip()
    r2 = subprocess.run(["python3", H + "/objcmp.py", TREE + "/objects/DCDDS2.obj", "#DDCDDS2", "S2", "--show", "3"], capture_output=True, text=True).stdout.strip()
    return r1, r2
def main(write):
    if not write:
        for f in ("APPLSRC/DCDDS2.hal",): shutil.copy("%s/OI340700/%s" % (PFS, f), "%s/%s" % (TREE, f))
        for n in dcdflt.MEMBERS.values():
            p = dcdgen.src_member(n); shutil.copy(p, "%s/INCL80/%s.hal" % (TREE, n))
        subprocess.run(["bash", "-c", 'cd "%s" && PATH="%s:$PATH" prepareINCLIB --clear --include=INCL80' % (TREE, PR)], capture_output=True)
        listing_compile(); print("\n".join(compare())); return 0
    members, origin = {}, {}
    for srn in dcdflt.MEMBERS:
        name, cards, kept, new, no, nf = dcdgen.rebuild(srn); members[name] = cards; origin[name] = dcdgen.rebuild.origin
    # DCDDS2's generated frame-length constants from DCD_FR_LEN in #DDCDDS2
    src = open("%s/OI340600/APPLSRC/DCDDS2.hal" % PFS).read()
    fr = [l for l in open(MAFGEN + "DASS_S2.ASC", errors="replace") if re.search(r"#DDCDDS2\+009C\s+[0-9A-F]{4}", l)]
    vals = [int(x, 16) for x in re.findall(r"\b([0-9A-F]{4})\b", fr[0].split("+009C")[1])] if fr else None
    names = ["LDR_SIZE_OF_24", "FRAME_LENGTH_OF_24", "LDR_SIZE_OF_26", "FRAME_LENGTH_OF_26"]
    for nm, v in zip(names, vals):
        src = re.sub(r"(%s INTEGER CONSTANT\(\s*)\d+" % nm, lambda m: m.group(1) + str(v), src)
    open(TREE + "/APPLSRC/DCDDS2.hal", "w").write(src)
    for it in range(20):
        install(members); listing_compile()
        F = semcmp.flight_stmts(); O = semcmp.our_stmts(F)
        bad = [st for st in F if F[st][1] != O.get(st)]
        if not bad: break
        for st in bad:
            s, fd = F[st]; name = dcdflt.MEMBERS[s["srn"]]
            k = next(i for i, x in enumerate(origin[name]) if (x["srn"], x["line"]) == (s["srn"], s["line"]))
            a = (fd[3] if fd[0] == "MVH" else [w for op, w in fd[1] if op in ("LH", "L", "LED")][0]) & 0x7FFF
            m = re.search(r"CSAS_INB_ENTRY\$\((\d+);\)$", dcdgen.G.resolve(a) or "")
            if not m or "CSAS_INB_ENTRY" not in members[name][k]: raise SystemExit("cannot repair ST#%d: %r" % (st, members[name][k]))
            members[name][k] = re.sub(r"CSAS_INB_ENTRY\$\(?(\d+);?\)?", "CSAS_INB_ENTRY$" + m.group(1), members[name][k])
    r1, r2 = compare(); print(r1); print(r2)
    return 0
if __name__ == "__main__":
    sys.exit(main("--write" in sys.argv))
