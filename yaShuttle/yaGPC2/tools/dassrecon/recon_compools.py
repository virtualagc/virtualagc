#!/usr/bin/env python3
"""Rebuild OI340700's SM compools from the DASS SM2 dump, and verify them.

    recon_compools.py            verify: compile each target as PFS holds it and
                                 compare #P<stem> with the dump
    recon_compools.py --write    regenerate every target whose OI340600 (or
                                 current OI340700) source does not already
                                 match, write it to PFS OI340700/APPLSRC with
                                 a provenance note, and verify what was written

A match means: the same size, every halfword equal once NAME pointers and
address constants are relocated to the dump's own addresses -- except where
the flight compiler emitted NO TEXT for an all-zero variable (HAL/S-FC emits
zeros), which is reported separately, and CPGPCD's CPGV_MM_PL_FTSBB copy 1,
which keeps its source value (the dump shows it starred).

Needs a scratch compile tree (paths.py) prepared from a tapebuild tree.
PFS 24af1848 is the result of --write.
"""
import re, os, sys, shutil, subprocess, json
H = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, H)
import cpgen
from paths import PFS, TREE, MAFGEN
TARGETS = [
 ("CSARST", "#PCSARST", {}), ("CSDMDT", "#PCSDMDT", {}), ("CPCDIT", "#PCPCDIT", {}), ("CPCVID", "#PCPCVID", {}),
 ("CPGPCD", "#PCPGPCD", {}), ("CPCTCI", "#PCPCTCI", {}), ("CPCANI", "#PCPCANI", {}), ("CPCPCI", "#PCPCPCI", {}),
 ("CP2GXT", "#PCP2GXT", dict(template=lambda n, v: "CPCS_GXT" if n.startswith("CPCV_GXT_") else None)),
 ("CS2DART", "#PCS2DAR", dict(template=lambda n, v: "CSAS_DART" if re.match(r"CSAS_DART_[A-Z]+ENTRY_\d+$", n) else None)),
 ("CS2PAR", "#PCS2PAR", {}), ("CPCCST", "#PCPCCST", {}), ("CS2IPT", "#PCS2IPT", {}),
 ("CSASAT", "#PCSASAT", {}), ("CRFASC", "#PCRFASC", {}), ("CPCCLT", "#PCPCCLT", {}),
 ("CRILVC", "#PCRILVC", dict(zero=("CRIS_CMD_BIAS", "CRIS_SPA_GAIN_SELECT", "CRIS_PH_GAIN_FACTOR_2", "CRIS_PH_GAIN_FACTOR_3"))),
 ("CPADOW", "#PCPADOW", {}), ("CSSCOT", "#PCSSCOT", {}), ("CRCCOT", "#PCRCCOT", {}), ("CPGSPL", "#PCPGSPL", {}),
 ("CRDCIL", "#PCRDCIL", {}), ("CPGGNC", "#PCPGGNC", {}), ("CSAPCT", "#PCSAPCT", {}), ("CS2INI", "#PCS2INI", {}),
 ("CPKCOT", "#PCPKCOT", dict(zero=("CPKS_REF_TIME", "CPKV_VAL_RAU_FLAG_WD"))), ("CSDHYB", "#PCSDHYB", {}),
 ("CPSSSU", "#PCPSSSU", {}), ("CPAMSP", "#PCPAMSP", {}),
]
KNOWN = {"CPGPCD": 1}          # differences kept on purpose (see the docstring)
def compile_cmp(stem, cs, sub):
    r = subprocess.run([H + "/hc.sh", stem, sub], capture_output=True, text=True)
    if "compiled" not in r.stdout: return False, None, "COMPILE FAILED"
    r = subprocess.run(["python3", H + "/objcmp.py", "%s/objects/%s.obj" % (TREE, stem), cs, "S2", "--show", "0"], capture_output=True, text=True)
    line = r.stdout.strip().splitlines()[-1]
    m = re.search(r"; (\d+) differ", line); z = re.search(r"ours (\d+) hw.*DASS S2 (\d+) hw", line)
    return bool(m and int(m.group(1)) <= KNOWN.get(stem, 0) and z and z.group(1) == z.group(2)), int(z.group(1)) if z else None, line
def main(write):
    tab = json.load(open(MAFGEN + "csects-S2.json")); bad = 0
    for stem, cs, kw in TARGETS:
        p, layer, sub = cpgen.source_path(stem)
        shutil.copy(p, "%s/%s/%s.hal" % (TREE, sub, stem))
        ok, size, line = compile_cmp(stem, cs, sub)
        if ok or not write:
            print("%-8s %s  %s  %s" % (stem, layer, "OK   " if ok else "DIFFERS", line)); bad += not ok; continue
        src, rep, path, layer, sub = cpgen.regenerate(stem, cs, verbose=False, **kw)
        text = src.render()
        open("%s/%s/%s.hal" % (TREE, sub, stem), "w").write(text)
        ok2, size2, line2 = compile_cmp(stem, cs, sub)
        nt = re.search(r"\+(\d+) where we emit 0000", line2); rep["_nottext"] = int(nt.group(1)) if nt else 0
        e = tab[cs]
        text = cpgen.header(text, stem, cs, layer, size, e["end"] - e["start"] + 1, rep, "%05X-%05X" % (e["start"], e["end"]))
        dst = "%s/OI340700/%s/%s.hal" % (PFS, sub, stem)
        open(dst, "w").write(text); shutil.copy(dst, "%s/%s/%s.hal" % (TREE, sub, stem))
        ok3, _, line3 = compile_cmp(stem, cs, sub)
        print("%-8s %s  WRITTEN %s  %s" % (stem, layer, "OK" if ok3 else "STILL DIFFERS", line3)); bad += not ok3
    return 1 if bad else 0
if __name__ == "__main__":
    sys.exit(main("--write" in sys.argv))
