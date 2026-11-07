#!/usr/bin/env python3
"""Aerial imagery for a portview landing site, from a Microsoft Flight Simulator add-on's .cgl file.

    python3 portview/msfs_cgl.py --site zza --zip "AirHispania LEZG Zaragoza v1.3.3.zip"
    python3 portview/msfs_cgl.py --site zza --cgl sai333.cgl
    python3 portview/msfs_cgl.py --site zza --restore        (the Sentinel-2 images back)

Needs numpy, Pillow and OpenCV (pip install opencv-python); portview itself does not.

WHAT A .CGL IS.  Microsoft's documentation (docs.flightsimulator.com, "CGL Files") says only that it is a container
of compressed imagery, elevation and vector data in a quadtree on a Web Mercator projection, authored at LOD 20
(0.1493 m/pixel at the equator).  Its binary layout is not documented and its index is compressed in a way this tool
does not decode.  What it does have, in the clear, is the imagery: every tile is an ordinary 256 x 256 RGBA PNG
(alpha 0 where the add-on defers to the simulator's own imagery), stored one after another.  The AirHispania LEZG
(Zaragoza) file holds 64,518 PNGs in four sizes, 256, 128, 64 and 32 pixels; this tool uses the 256-pixel ones, which
are the finest levels (LOD 17 at 0.89 m/pixel and LOD 16 at 1.78 m/pixel there).

HOW A TILE IS PLACED WITHOUT THE INDEX.
  1. Carve every PNG (signature to IEND) out of the file.
  2. Put the fully opaque 256-pixel tiles back together.  Neighbouring tiles continue each other's pixels, so for every
     pair the dissimilarity of their facing edges (each extrapolated across the seam) is measured; a pair counts only if
     it is the best for both tiles and at least 1.7 times better than the runner-up.  A breadth-first walk over those
     pairs gives each tile a grid position; a walk that ever disagrees with itself is reported (LEZG: 614 tiles, 0
     conflicts).  A group of fewer than MIN_TILES tiles is dropped.
  3. Find where each group is on the Earth by matching SIFT features against the site's Sentinel-2 ring
     (cache/sites/SITE/ring1.jpg, 9.8 m/pixel) and fitting a similarity transform with RANSAC.  The fitted scale gives
     the tile level (1.0 = LOD 17, 2.0 = LOD 16, ...), and the group's top-left corner has to fall within 0.25 of a
     tile on that level's Web Mercator grid, which it does by 0.02-0.08 for LEZG, so it is snapped to the grid and
     the placement is exact, not merely fitted.
  4. Write the ring images (below).

OUTPUT, in the git-ignored cache, for the site SITE (the existing Sentinel-2 images are kept as *_s2.jpg and ring.json
as ring.json.s2, and --restore puts them back):
  ring0.jpg   +-4 km, 8192 pixels (about 1 m/pixel, as KSC's NAIP ring): the finest tile level that covers each
              point, over the Sentinel-2 ring where the add-on has no tile; the aerial's colour is moved 30% of the
              way to Sentinel's per-channel mean so the seams are gentle (--keep 0 leaves the photograph alone)
  ringF.jpg   +-1.5 km, 4096 pixels (0.73 m/pixel, about the source's 0.89): the fine ring KSC has
  ring.json   'fine' added and ring 0's source named

TERMS.  The add-ons are third-party works, not Microsoft's, and are subject to whatever terms their authors give.  The
LEZG package states none: no licence text, no copyright notice, no source for its aerial photography (its manifest
names only the creator, AirHispania / AHS9083; its instructions are install notes).  The images go into the
git-ignored cache only and are not committed; what may be done with a published render of them is for the person who
holds the download to decide.

Verified on Linux only (LEZG, 2026-11-07).
"""
import argparse
import io
import json
import math
import os
import re
import shutil
import sys
import zipfile

import numpy as np
from PIL import Image

try:
    import cv2
except ImportError:
    sys.exit("msfs_cgl: needs OpenCV: pip install opencv-python")

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
SITES = os.path.join(HERE, "cache", "sites")
SIG, END = b"\x89PNG\r\n\x1a\n", b"IEND\xaeB`\x82"
MIN_TILES = 10                 # smaller groups are dropped
PAIR_RATIO = 0.6               # best pair must be this much better than the runner-up
SNAP_TOL = 0.25                # tiles: how far a corner may be from the Mercator grid
MIN_INLIERS = 10
RING0_PX, FINE_PX, FINE_HALF_KM = 8192, 4096, 1.5
LOD0 = 17                      # the level a scale of 1.0 means


def log(*a):
    print("msfs_cgl:", *a, flush=True)


def read_cgl(args):
    if args.cgl:
        return open(args.cgl, "rb").read()
    with zipfile.ZipFile(args.zip) as z:
        names = [n for n in z.namelist() if n.lower().endswith(".cgl")]
        if not names:
            sys.exit("msfs_cgl: no .cgl in %s (a package without ground imagery, like KTTS's)" % args.zip)
        log("reading", names[0])
        return z.read(names[0])


def carve(d):
    """Every 256-pixel RGBA PNG in the file: (array, fully_opaque)."""
    tiles, pos, sizes = [], 0, {}
    while True:
        s = d.find(SIG, pos)
        if s < 0:
            break
        e = d.find(END, s)
        if e < 0:
            break
        e += 8
        try:
            im = Image.open(io.BytesIO(d[s:e]))
            im.load()
            sizes[im.size[0]] = sizes.get(im.size[0], 0) + 1
            if im.size == (256, 256) and im.mode == "RGBA":
                tiles.append(np.array(im))
            pos = e
        except Exception:
            pos = s + 8
    log("carved PNGs by width:", dict(sorted(sizes.items())))
    return tiles


def edge_pairs(F):
    """Mutual best, ratio-tested horizontal and vertical neighbour pairs among the opaque tiles F (m,256,256,3)."""
    m = len(F)
    f = F.astype(np.float32)
    R1, R2 = f[:, :, -1, :].reshape(m, -1), f[:, :, -2, :].reshape(m, -1)
    L1, L2 = f[:, :, 0, :].reshape(m, -1), f[:, :, 1, :].reshape(m, -1)
    B1, B2 = f[:, -1, :, :].reshape(m, -1), f[:, -2, :, :].reshape(m, -1)
    T1, T2 = f[:, 0, :, :].reshape(m, -1), f[:, 1, :, :].reshape(m, -1)

    def dis(a1, a2, b1, b2):
        P, Q = 2 * a1 - a2, 2 * b1 - b2
        D = np.zeros((m, m), np.float32)
        for i in range(m):
            D[i] = np.abs(b1 - P[i]).mean(1) + np.abs(a1[i] - Q).mean(1)
        np.fill_diagonal(D, 1e9)
        return D

    def mutual(D):
        best, bestr, srt, out = D.argmin(1), D.argmin(0), np.sort(D, 1), []
        for i in range(m):
            j = best[i]
            if bestr[j] == i and srt[i, 0] < PAIR_RATIO * srt[i, 1]:
                out.append((i, int(j)))
        return out

    return mutual(dis(R1, R2, L1, L2)), mutual(dis(B1, B2, T1, T2))


def groups(m, H, V):
    adj = {i: [] for i in range(m)}
    for i, j in H:
        adj[i].append((j, 1, 0)); adj[j].append((i, -1, 0))
    for i, j in V:
        adj[i].append((j, 0, 1)); adj[j].append((i, 0, -1))
    seen, out = set(), []
    for s in range(m):
        if s in seen:
            continue
        pos, q, conflicts = {s: (0, 0)}, [s], 0
        seen.add(s)
        while q:
            u = q.pop()
            for v, dx, dy in adj[u]:
                p = (pos[u][0] + dx, pos[u][1] + dy)
                if v in pos:
                    conflicts += pos[v] != p
                else:
                    pos[v] = p; seen.add(v); q.append(v)
        out.append((pos, conflicts))
    return sorted(out, key=lambda g: -len(g[0]))


def tile_xy(lon, lat, z):
    n = 2 ** z
    return ((lon + 180) / 360 * n,
            (1 - math.log(math.tan(math.radians(lat)) + 1 / math.cos(math.radians(lat))) / math.pi) / 2 * n)


def merc_y(lat, z):
    return tile_xy(0, lat, z)[1]


def place(groups_, tiles_opaque, site):
    """SIFT-register each group against the site's Sentinel-2 ring1; snap to the Web Mercator grid.
    Returns [dict(mosaic, mask, x0, y0, z)] finest first."""
    d = os.path.join(SITES, site)
    rj = json.load(open(os.path.join(d, "ring.json")))
    ref = rj["rings"][1]
    src1 = os.path.join(d, "ring1_s2.jpg") if os.path.exists(os.path.join(d, "ring1_s2.jpg")) else os.path.join(d, ref["file"])
    R = np.array(Image.open(src1).convert("L"))
    b = ref["bounds"]
    lat0 = (b[1] + b[3]) / 2
    ring_mpp = (b[2] - b[0]) * 111320 * math.cos(math.radians(lat0)) / R.shape[1]
    mpp0 = 156543.03392 * math.cos(math.radians(lat0)) / 2 ** LOD0
    f = mpp0 / ring_mpp
    sift = cv2.SIFT_create(nfeatures=40000, contrastThreshold=0.02)
    kr, dr = sift.detectAndCompute(R, None)
    log("ring1 %s: %d features, %.2f m/px; a LOD%d tile is %.3f of a ring pixel" % (os.path.basename(src1), len(kr), ring_mpp, LOD0, f))
    placed = []
    for gi, (pos, conflicts) in enumerate(groups_):
        if len(pos) < MIN_TILES:
            continue
        xs, ys = [p[0] for p in pos.values()], [p[1] for p in pos.values()]
        gx0, gy0 = min(xs), min(ys)
        W, H = max(xs) - gx0 + 1, max(ys) - gy0 + 1
        M = np.zeros((H * 256, W * 256, 3), np.uint8)
        K = np.zeros((H * 256, W * 256), np.uint8)
        for k, (x, y) in pos.items():
            M[(y - gy0) * 256:(y - gy0 + 1) * 256, (x - gx0) * 256:(x - gx0 + 1) * 256] = tiles_opaque[k]
            K[(y - gy0) * 256:(y - gy0 + 1) * 256, (x - gx0) * 256:(x - gx0 + 1) * 256] = 255
        G = cv2.cvtColor(M, cv2.COLOR_RGB2GRAY)
        Gs = cv2.resize(G, None, fx=f, fy=f, interpolation=cv2.INTER_AREA)
        Ks = (cv2.resize(K, None, fx=f, fy=f, interpolation=cv2.INTER_NEAREST) > 0).astype(np.uint8) * 255
        kg, dg = sift.detectAndCompute(Gs, Ks)
        tag = "group %d (%d tiles, %d x %d, %d conflicts)" % (gi, len(pos), W, H, conflicts)
        if len(kg) < 8:
            log(tag, ": too few features, dropped"); continue
        mm = cv2.BFMatcher().knnMatch(dg, dr, k=2)
        good = [a for a, c in mm if a.distance < 0.8 * c.distance]
        if len(good) < 6:
            log(tag, ": %d good matches, dropped" % len(good)); continue
        s_ = np.float32([kg[a.queryIdx].pt for a in good]); d_ = np.float32([kr[a.trainIdx].pt for a in good])
        T, inl = cv2.estimateAffinePartial2D(s_, d_, method=cv2.RANSAC, ransacReprojThreshold=4.0, maxIters=20000, confidence=0.999)
        if T is None or int(inl.sum()) < MIN_INLIERS:
            log(tag, ": no registration (%s inliers), dropped" % (0 if T is None else int(inl.sum()))); continue
        scale = math.hypot(T[0, 0], T[1, 0])
        rot = math.degrees(math.atan2(T[1, 0], T[0, 0]))
        lv = LOD0 - math.log2(scale)
        z = int(round(lv))
        lon = b[0] + T[0, 2] / R.shape[1] * (b[2] - b[0])
        lat = b[3] - T[1, 2] / R.shape[0] * (b[3] - b[1])
        x, y = tile_xy(lon, lat, z)
        x0, y0 = round(x), round(y)
        ok = abs(lv - z) < 0.1 and abs(rot) < 0.5 and abs(x - x0) < SNAP_TOL and abs(y - y0) < SNAP_TOL
        log(tag, ": %d inliers, scale %.3f (LOD %.2f), rotation %.2f deg, corner on LOD%d grid at x %.3f y %.3f -> %s" %
            (int(inl.sum()), scale, lv, rot, z, x, y, "snapped to (%d, %d)" % (x0, y0) if ok else "REJECTED (not on the grid)"))
        if ok:
            placed.append(dict(M=M, K=K, x0=x0, y0=y0, z=z))
    placed.sort(key=lambda p: -p["z"])
    return placed


def build_ring(layers, bounds, N, base_path, base_bounds, out_path, keep, strip=512):
    S = np.array(Image.open(base_path).convert("RGB"))
    lons = bounds[0] + (np.arange(N) + 0.5) / N * (bounds[2] - bounds[0])
    lats = bounds[3] - (np.arange(N) + 0.5) / N * (bounds[3] - bounds[1])
    sx = ((lons - base_bounds[0]) / (base_bounds[2] - base_bounds[0]) * S.shape[1] - 0.5).astype(np.float32)
    sy = ((base_bounds[3] - lats) / (base_bounds[3] - base_bounds[1]) * S.shape[0] - 0.5).astype(np.float32)
    base = np.zeros((N, N, 3), np.uint8)
    lay = []
    for L in layers:
        mx = (((lons + 180) / 360 * 2 ** L["z"] - L["x0"]) * 256 - 0.5).astype(np.float32)
        my = np.array([(merc_y(l, L["z"]) - L["y0"]) * 256 - 0.5 for l in lats], np.float32)
        lay.append(dict(L=L, mx=mx, my=my, rgb=np.zeros((N, N, 3), np.uint8), cov=np.zeros((N, N), np.float32)))
    for r in range(0, N, strip):
        r1 = min(N, r + strip)
        base[r:r1] = cv2.remap(S, np.tile(sx[None, :], (r1 - r, 1)), np.tile(sy[r:r1, None], (1, N)),
                               cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
        for e in lay:
            MX = np.tile(e["mx"][None, :], (r1 - r, 1)); MY = np.tile(e["my"][r:r1, None], (1, N))
            e["rgb"][r:r1] = cv2.remap(e["L"]["M"], MX, MY, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)
            e["cov"][r:r1] = cv2.remap(e["L"]["K"], MX, MY, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0).astype(np.float32) / 255
    inside = lay[0]["cov"] > 0.99
    off = np.zeros(3, np.float32)
    if inside.any() and keep:
        sm = cv2.resize(base, (N // 8, N // 8), interpolation=cv2.INTER_AREA).astype(np.float32)
        am = cv2.resize(lay[0]["rgb"], (N // 8, N // 8), interpolation=cv2.INTER_AREA).astype(np.float32)
        cm = cv2.resize(inside.astype(np.uint8), (N // 8, N // 8), interpolation=cv2.INTER_NEAREST) > 0
        if cm.any():
            off = np.array([keep * float(sm[..., c][cm].mean() - am[..., c][cm].mean()) for c in range(3)], np.float32)
    log("%s: finest level covers %.1f%% of the ring; colour shift %s" % (os.path.basename(out_path), 100 * inside.mean(), np.round(off, 1)))
    res = base.astype(np.float32)
    for e in reversed(lay):                      # coarse first, the finest on top
        k = cv2.erode((e["cov"] > 0.99).astype(np.uint8), np.ones((3, 3), np.uint8), iterations=max(2, N // 1024))
        al = cv2.GaussianBlur(k.astype(np.float32), (0, 0), max(3, N / 340.0))[..., None]
        res = np.clip(e["rgb"].astype(np.float32) * al + res * (1 - al) + off * al, 0, 255)
    Image.fromarray(res.astype(np.uint8)).save(out_path, quality=93, subsampling=0)


def restore(d):
    done = False
    for name in ("ring0", "ring1"):
        s2 = os.path.join(d, name + "_s2.jpg")
        if os.path.exists(s2):
            shutil.copyfile(s2, os.path.join(d, name + ".jpg")); done = True
    if os.path.exists(os.path.join(d, "ring.json.s2")):
        shutil.copyfile(os.path.join(d, "ring.json.s2"), os.path.join(d, "ring.json")); done = True
    if os.path.exists(os.path.join(d, "ringF.jpg")):
        os.remove(os.path.join(d, "ringF.jpg")); done = True
    log("restored the Sentinel-2 images" if done else "nothing to restore")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[1], formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--site", required=True, help="the portview site (cache/sites/SITE must exist: fetch_assets.py --sites SITE)")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--zip", help="the add-on's zip file")
    g.add_argument("--cgl", help="a .cgl file")
    g.add_argument("--restore", action="store_true", help="put the Sentinel-2 images back")
    ap.add_argument("--keep", type=float, default=0.3, help="fraction of the colour shift toward Sentinel's means (default 0.3)")
    args = ap.parse_args()
    d = os.path.join(SITES, args.site)
    if not os.path.exists(os.path.join(d, "ring.json")):
        sys.exit("msfs_cgl: no cache/sites/%s (run portview/fetch_assets.py --sites %s first)" % (args.site, args.site))
    if args.restore:
        return restore(d)
    if not (args.zip or args.cgl):
        sys.exit("msfs_cgl: give --zip or --cgl (or --restore)")
    # the Sentinel-2 originals, once
    for name in ("ring0", "ring1"):
        s2 = os.path.join(d, name + "_s2.jpg")
        if not os.path.exists(s2):
            shutil.copyfile(os.path.join(d, name + ".jpg"), s2)
    if not os.path.exists(os.path.join(d, "ring.json.s2")):
        shutil.copyfile(os.path.join(d, "ring.json"), os.path.join(d, "ring.json.s2"))
    rj = json.load(open(os.path.join(d, "ring.json.s2")))
    tiles = carve(read_cgl(args))
    opaque = [t[..., :3] for t in tiles if (t[..., 3] > 250).all()]
    log("%d tiles of 256 px, %d fully opaque" % (len(tiles), len(opaque)))
    H, V = edge_pairs(np.array(opaque))
    gs = groups(len(opaque), H, V)
    log("%d confident horizontal and %d vertical pairs; group sizes %s" % (len(H), len(V), [len(g[0]) for g in gs[:8]]))
    layers = place(gs, opaque, args.site)
    if not layers:
        sys.exit("msfs_cgl: no group could be placed")
    b0 = rj["rings"][0]["bounds"]
    lat, lon = rj["lat"], rj["lon"]
    dl = FINE_HALF_KM / 110.574
    dn = FINE_HALF_KM / (111.320 * math.cos(math.radians(lat)))
    bf = [lon - dn, lat - dl, lon + dn, lat + dl]
    base0 = os.path.join(d, "ring0_s2.jpg")
    build_ring(layers, bf, FINE_PX, base0, b0, os.path.join(d, "ringF.jpg"), args.keep)
    build_ring(layers, b0, RING0_PX, base0, b0, os.path.join(d, "ring0.jpg"), args.keep)
    rj["rings"][0]["source"] = "msfs-cgl+s2"
    rj["fine"] = {"file": "ringF.jpg", "bounds": bf, "half_km": FINE_HALF_KM, "source": "msfs-cgl"}
    rj["name"] = rj.get("name", args.site).split(" -- ")[0] + " -- MSFS aerial imagery (%s)" % os.path.basename(args.zip or args.cgl)
    json.dump(rj, open(os.path.join(d, "ring.json"), "w"), indent=1)
    log("done:", ", ".join("LOD%d tiles x %d..%d y %d..%d" % (L["z"], L["x0"], L["x0"] + L["M"].shape[1] // 256 - 1,
                                                                L["y0"], L["y0"] + L["M"].shape[0] // 256 - 1) for L in layers))


if __name__ == "__main__":
    main()
