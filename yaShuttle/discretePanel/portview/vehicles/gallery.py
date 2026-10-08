#!/usr/bin/env python3
"""A contact sheet of every prepared vehicle (preview.py's six views each),
and an HTML page showing them with their names, sizes and sources.

    python3 portview/vehicles/gallery.py OUT_DIR [--only KEY,...]
"""
import argparse
import html
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PANEL = os.path.dirname(os.path.dirname(HERE))
MODELS = os.path.join(PANEL, "portview", "cache", "models")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("out")
    ap.add_argument("--only")
    ap.add_argument("--size", type=int, default=300)
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    only = set(a.only.split(",")) if a.only else None
    rows = []
    for key in sorted(os.listdir(MODELS)):
        try:
            meta = json.load(open(os.path.join(MODELS, key, "model.json")))
        except (OSError, ValueError):
            continue
        if not meta.get('norad') or (only and key not in only):
            continue
        sheet = os.path.join(a.out, "%s.png" % key)
        subprocess.run([sys.executable, os.path.join(HERE, "preview.py"), key, "--out", sheet,
                        "--size", str(a.size)], cwd=PANEL, check=False, stdout=subprocess.DEVNULL)
        rows.append((key, meta))
        print(key, flush=True)
    page = ["<!doctype html><meta charset=utf-8><title>portview vehicles</title>",
            "<style>body{background:#111;color:#ddd;font:15px system-ui;margin:16px}"
            "img{max-width:100%;border:1px solid #333}h2{margin:28px 0 4px}p{margin:2px 0;color:#aaa}</style>",
            "<h1>portview's vehicles</h1>"]
    for key, m in rows:
        page.append("<h2>%s</h2><p>NORAD %s &middot; %s triangles &middot; %s</p><p>%s</p>"
                    "<img src='%s.png' alt='%s'>" % (html.escape(m['name']), m.get('norad'),
                                                     m.get('triangles'), html.escape(m.get('frame', '')),
                                                     html.escape(m.get('source', '')), key, key))
    open(os.path.join(a.out, "index.html"), "w").write("\n".join(page))
    print(os.path.join(a.out, "index.html"))


if __name__ == "__main__":
    main()
