#!/usr/bin/env python3
"""Aerial imagery for a portview landing site, from a Microsoft Flight Simulator add-on's .cgl file.

    python3 portview/msfs_cgl.py --site zza --zip "AirHispania LEZG Zaragoza v1.3.3.zip"
    python3 portview/msfs_cgl.py --site zza --cgl sai333.cgl
    python3 portview/msfs_cgl.py --site esn --zip LTAC.zip --new-site "Ankara Esenboga (LTAC)" --lat 40.12774 --lon 32.99652 \\
        --alt-ft 3133 --delh-ft 22 --runway 40.11514,32.98486,40.14033,33.00819
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
  3. Find where each group is on the Earth by matching SIFT features against the site's Sentinel-2 rings (ring1, 9.8 m/px,
     and ring0) and fitting a similarity transform with RANSAC, under several hypotheses of the group's tile level
     (the mosaic is scaled to the reference's resolution under each; the fitted scale then gives the level to a
     fraction of a level, and the group's top-left corner lands on that level's Web Mercator grid).  The level with
     the most inliers wins and the position is the inlier-weighted mean.  A tile at least 36 m wide whose corner is
     within 18 m of the grid is snapped to it (LEZG: corners within 5 m, 0.02-0.08 of a tile, 0 conflicts).  A finer
     group (Wilmington's level 20 is 0.12 m/px, a 32 m tile) cannot be fixed to a tile by a 10 m reference, so it is
     placed by correlating it with a coarser mosaic already placed, the same photograph at lower resolution:
     among the 3 x 3 grid positions round the estimate the right one stands out (NCC 0.998, 0.77 ahead of the next).
  4. Write the ring images (below).

OUTPUT, in the git-ignored cache, for the site SITE (the existing Sentinel-2 images are kept as *_s2.jpg and ring.json
as ring.json.s2, and --restore puts them back):
  ring0.jpg   +-4 km, 8192 pixels (about 1 m/pixel, as KSC's NAIP ring): the finest tile level that covers each
              point, over the Sentinel-2 ring where the add-on has no tile; the aerial's colour is moved 30% of the
              way to Sentinel's per-channel mean so the seams are gentle (--keep 0 leaves the photograph alone)
  ringF.jpg   +-1.5 km, 4096-8192 pixels sized to the finest source level (LEZG: 4096, 0.73 m/px for 0.89; finer
              sources 8192, KSC's own size): the fine ring KSC has
  ring.json   'fine' added and ring 0's source named

TERMS.  The add-ons are third-party works, not Microsoft's, and are subject to whatever terms their authors give.  The
LEZG package states none: no licence text, no copyright notice, no source for its aerial photography (its manifest
names only the creator, AirHispania / AHS9083; its instructions are install notes).  The images go into the
git-ignored cache only and are not committed; what may be done with a published render of them is for the person who
holds the download to decide.

Verified on Linux only (2026-11-07): LEZG Zaragoza (LOD 17/16/15), LTAC Ankara (18/17/16), EDDK Koeln/Bonn (19/18/17),
KILM Wilmington (20/19/18).  Memory: about 17 GB peak for the largest (Wilmington); the SIFT copies are capped at MAX_SIFT px.
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
SNAP_M = 18.0                  # metres: how far an estimated corner may be from the Mercator grid and still be snapped to it
SNAP_UNIQUE_M = 36.0           # a tile narrower than this cannot be told from its neighbours by a Sentinel-2 registration
MIN_INLIERS = 10
HYPOTHESES = (19, 18, 17, 16, 20, 15)   # the tile levels a mosaic may be, tried in this order
MAX_SIFT = 3500                # px: the longest side of a mosaic copy handed to SIFT
RING0_PX, FINE_HALF_KM = 8192, 1.5        # ring 0 as KSC's NAIP ring (about 1 m/px); the fine ring is sized to the source, below
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
    e = lambda a: a.astype(np.float32).reshape(m, -1)       # only the edge rows/columns as float, not every tile
    R1, R2 = e(F[:, :, -1, :]), e(F[:, :, -2, :])
    L1, L2 = e(F[:, :, 0, :]), e(F[:, :, 1, :])
    B1, B2 = e(F[:, -1, :, :]), e(F[:, -2, :, :])
    T1, T2 = e(F[:, 0, :, :]), e(F[:, 1, :, :])

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


def native_mpp(lat, z):
    """Ground metres per pixel of a 256-px Web Mercator tile at level z."""
    return 156543.03392 * math.cos(math.radians(lat)) / 2 ** z


def refine(e, cx, cy, z, placed, lat):
    """The exact tile corner of a group too fine for the Sentinel-2 reference to fix (a tile under SNAP_UNIQUE_M wide):
    among the 3 x 3 grid positions round the estimate, the one whose imagery best correlates (zero-mean NCC, at about
    1 m/px) with a coarser, already placed mosaic of the same photography.  Returns (x0, y0, ncc, margin) or None."""
    coarser = [pl for pl in placed if pl["z"] < z]
    if not coarser:
        return None
    ref = max(coarser, key=lambda pl: pl["z"])
    down = max(1, int(round(1.0 / native_mpp(lat, z))))
    if "Gd" not in e:
        e["Gd"] = cv2.resize(cv2.cvtColor(e["M"], cv2.COLOR_RGB2GRAY), None, fx=1.0 / down, fy=1.0 / down, interpolation=cv2.INTER_AREA)
        e["Kd"] = cv2.resize(e["K"], None, fx=1.0 / down, fy=1.0 / down, interpolation=cv2.INTER_NEAREST)
    if "G" not in ref:
        ref["G"] = cv2.cvtColor(ref["M"], cv2.COLOR_RGB2GRAY)
    Gd, Kd = e["Gd"], e["Kd"]
    h, w = Gd.shape
    scale = 2 ** (z - ref["z"])
    u = ((np.arange(w) + 0.5) * down) / 256.0          # tile units from the group's left edge, at level z
    v = ((np.arange(h) + 0.5) * down) / 256.0
    scores = []
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            X0, Y0 = round(cx) + dx, round(cy) + dy
            U = (((X0 + u) / scale - ref["x0"]) * 256 - 0.5).astype(np.float32)
            V = (((Y0 + v) / scale - ref["y0"]) * 256 - 0.5).astype(np.float32)
            mx, my = np.tile(U[None, :], (h, 1)), np.tile(V[:, None], (1, w))
            Rg = cv2.remap(ref["G"], mx, my, cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=0)
            Rk = cv2.remap(ref["K"], mx, my, cv2.INTER_NEAREST, borderMode=cv2.BORDER_CONSTANT, borderValue=0)
            ok = (Kd > 128) & (Rk > 128)
            if ok.sum() < 20000:
                continue
            a_, b_ = Gd[ok].astype(np.float64), Rg[ok].astype(np.float64)
            a_ -= a_.mean(); b_ -= b_.mean()
            d_ = math.sqrt((a_ ** 2).sum() * (b_ ** 2).sum())
            scores.append((float((a_ * b_).sum() / d_) if d_ > 0 else -1.0, X0, Y0))
    if len(scores) < 2:
        return None
    scores.sort(reverse=True)
    return scores[0][1], scores[0][2], scores[0][0], scores[0][0] - scores[1][0]


def place(groups_, tiles_opaque, site):
    """SIFT-register each group against the site's Sentinel-2 rings (ring1, then ring0) under several hypotheses of its
    tile level, then place it on the Web Mercator grid.
    Pass 1 gathers, for every group, each registration that is plausible (scale an exact power of two to 0.1 of a
    level, rotation under 0.6 deg, at least 4 inliers).  The level with the most inliers wins and the position is the
    inlier-weighted mean of its registrations.
    Pass 2, coarsest group first: a tile at least SNAP_UNIQUE_M wide whose estimated corner is within SNAP_M of the grid
    is snapped to it (Sentinel-2's accuracy is about 15 m, so a narrower tile cannot be chosen that way); a finer group
    is placed by refine(), the correlation against a coarser mosaic already placed.
    Returns [dict(M, K, x0, y0, z)] finest first."""
    d = os.path.join(SITES, site)
    rj = json.load(open(os.path.join(d, "ring.json.s2" if os.path.exists(os.path.join(d, "ring.json.s2")) else "ring.json")))
    site_lat = rj["lat"]
    sift = cv2.SIFT_create(nfeatures=40000, contrastThreshold=0.02)
    refs = []
    for k in (1, 0):
        name = "ring%d_s2.jpg" % k
        path = os.path.join(d, name) if os.path.exists(os.path.join(d, name)) else os.path.join(d, rj["rings"][k]["file"])
        R = np.array(Image.open(path).convert("L"))
        if k == 0 and R.shape[0] > 2048:  # a Sentinel-2 ring stored at 8192 px (a site fetched with default ring sizes) is the
            R = cv2.resize(R, (2048, 2048), interpolation=cv2.INTER_AREA)    # same 10 m data upsampled: match at 2048
        b = rj["rings"][k]["bounds"]
        lat0 = (b[1] + b[3]) / 2
        ring_mpp = (b[2] - b[0]) * 111320 * math.cos(math.radians(lat0)) / R.shape[1]
        f = native_mpp(lat0, LOD0) / ring_mpp
        kr, dr = sift.detectAndCompute(R, None)
        log("reference %s: %d features, %.2f m/px; a LOD%d tile is %.3f of a pixel there" % (name, len(kr), ring_mpp, LOD0, f))
        refs.append(dict(name=name, shape=R.shape, b=b, f=f, kr=kr, dr=dr))
    ests = []
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
        tag = "group %d (%d tiles, %d x %d, %d conflicts)" % (gi, len(pos), W, H, conflicts)
        cands = []
        for ref in refs:
            for L in HYPOTHESES:
                # under the hypothesis that this mosaic is level L its pixel is 2**(L-17) times smaller than a LOD17
                # one: scale it to the reference's resolution so SIFT sees two images at the same scale
                f0 = ref["f"] / 2 ** (L - LOD0)
                if G.shape[0] * f0 < 24 or G.shape[1] * f0 < 24:
                    continue
                # SIFT upsamples its input, so a mosaic tens of thousands of pixels across needs tens of GB:
                # register a copy at most MAX_SIFT px across and correct the scale afterwards
                r = min(1.0, MAX_SIFT / (max(G.shape) * f0))
                f = f0 * r
                Gs = cv2.resize(G, None, fx=f, fy=f, interpolation=cv2.INTER_AREA)
                Ks = (cv2.resize(K, None, fx=f, fy=f, interpolation=cv2.INTER_NEAREST) > 0).astype(np.uint8) * 255
                kg, dg = sift.detectAndCompute(Gs, Ks)
                if len(kg) < 8:
                    continue
                mm = cv2.BFMatcher().knnMatch(dg, ref["dr"], k=2)
                good = [a for a, c in mm if a.distance < 0.8 * c.distance]
                if len(good) < 5:
                    continue
                s_ = np.float32([kg[a.queryIdx].pt for a in good]); d_ = np.float32([ref["kr"][a.trainIdx].pt for a in good])
                T, inl = cv2.estimateAffinePartial2D(s_, d_, method=cv2.RANSAC, ransacReprojThreshold=4.0, maxIters=20000, confidence=0.999)
                if T is None:
                    continue
                ratio = math.hypot(T[0, 0], T[1, 0]) * r        # 1.0: the hypothesis was right
                if ratio <= 0.05:
                    continue
                ni = int(inl.sum())
                rot = math.degrees(math.atan2(T[1, 0], T[0, 0]))
                lv = L - math.log2(ratio)
                z = int(round(lv))
                b, shp = ref["b"], ref["shape"]
                lon = b[0] + T[0, 2] / shp[1] * (b[2] - b[0])
                lat = b[3] - T[1, 2] / shp[0] * (b[3] - b[1])
                x, y = tile_xy(lon, lat, z)
                plausible = ni >= 4 and abs(lv - z) < 0.1 and abs(rot) < 0.6
                if ni >= 4:
                    log(tag, "vs %s as LOD%d: %d inliers, scale ratio %.3f (LOD %.2f), rotation %.2f deg, corner on LOD%d grid at x %.3f y %.3f%s" %
                        (ref["name"], L, ni, ratio, lv, rot, z, x, y, "" if plausible else " (implausible)"))
                if plausible:
                    cands.append((ni, z, x, y))
        del G
        ests.append(dict(gi=gi, n=len(pos), M=M, K=K, cands=cands, tag=tag))
    # pass 2, coarsest first
    for e in ests:
        byz = {}
        for ni, z, x, y in e["cands"]:
            byz[z] = byz.get(z, 0) + ni
        e["z"] = max(byz, key=byz.get) if byz else None
        e["w"] = byz.get(e["z"], 0) if byz else 0
    placed = []
    for e in sorted(ests, key=lambda e: (e["z"] is None, e["z"] if e["z"] is not None else 0)):
        tag = e["tag"]
        if e["z"] is None or (e["w"] < 8 and not any(c[1] == e["z"] and c[0] >= 5 for c in e["cands"])):
            log(tag, ": no usable registration, dropped"); continue
        z = e["z"]
        cs = [c for c in e["cands"] if c[1] == z]
        wsum = float(sum(c[0] for c in cs))
        cx = sum(c[0] * c[2] for c in cs) / wsum
        cy = sum(c[0] * c[3] for c in cs) / wsum
        tile_m = native_mpp(site_lat, z) * 256
        err_m = max(abs(cx - round(cx)), abs(cy - round(cy))) * tile_m
        if tile_m >= SNAP_UNIQUE_M and err_m <= SNAP_M:
            placed.append(dict(M=e["M"], K=e["K"], x0=round(cx), y0=round(cy), z=z))
            log(tag, ": LOD%d (%.2f m/px), %d inliers over %d registrations, corner x %.3f y %.3f is %.0f m from the grid -> snapped to (%d, %d)" %
                (z, native_mpp(site_lat, z), e["w"], len(cs), cx, cy, err_m, round(cx), round(cy)))
            continue
        res = refine(e, cx, cy, z, placed, site_lat)
        if res is not None and res[2] >= 0.5 and res[3] >= 0.05:
            placed.append(dict(M=e["M"], K=e["K"], x0=res[0], y0=res[1], z=z))
            log(tag, ": LOD%d (%.2f m/px), tile %.0f m wide is too narrow for Sentinel-2 to fix; correlation with a coarser mosaic picks (%d, %d): NCC %.3f, %.3f ahead of the next -> placed" %
                (z, native_mpp(site_lat, z), tile_m, res[0], res[1], res[2], res[3]))
        else:
            log(tag, ": LOD%d, corner x %.3f y %.3f is %.0f m from the grid (tile %.0f m wide); %s -> dropped" %
                (z, cx, cy, err_m, tile_m, "no coarser mosaic to refine against" if res is None else "correlation %.3f, margin %.3f too weak" % (res[2], res[3])))
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


def ensure_site(args):
    """--new-site: define a site that fetch_assets.py does not know and fetch its Sentinel-2 (or NAIP, with --naip YEAR)
    rings and terrain heights, by calling fetch_assets's own per-site functions with the definition injected into its
    SITES (so fetch_assets.py itself is not edited).  Does nothing if cache/sites/SITE already exists."""
    d = os.path.join(SITES, args.site)
    if args.lat is None or args.lon is None or args.alt_ft is None:
        sys.exit("msfs_cgl: --new-site needs --lat, --lon (the runway's midpoint) and --alt-ft (above PASS's ellipsoid)")
    sys.path.insert(0, HERE)
    import fetch_assets as F                              # each prepare_site* skips what is already prepared
    site = dict(name=args.new_site, lat=args.lat, lon=args.lon, alt_ft=args.alt_ft)
    if args.delh_ft is not None:
        site["delh_ft"] = args.delh_ft
    site["dem"] = "world"                                # AWS terrain tiles (~30 m): works wherever Python's fetch does
    if args.naip:
        site["naip"] = True
        site["naip_year"] = args.naip
    else:
        site["ring_px"] = (2048, 8192, 4096, 4096)       # Sentinel-2's 10 m: 2048 px for the +-4 km ring, as zza
        if args.runway:
            site["runways"] = tuple(tuple(float(v) for v in r.split(",")) + ((45.0,) if r.count(",") == 3 else ())
                                    for r in args.runway)
    F.SITES[args.site] = site
    log("new site", args.site, site)
    F.prepare_site(args.site)
    F.prepare_site_fine(args.site)
    F.prepare_site_patches(args.site)
    F.prepare_site_heights(args.site)


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
    ap.add_argument("--new-site", metavar="NAME", help="define the site (cache/sites/SITE does not exist): its name, with --lat --lon --alt-ft")
    ap.add_argument("--lat", type=float, help="--new-site: the runway midpoint's geodetic latitude, degrees")
    ap.add_argument("--lon", type=float, help="--new-site: its longitude, degrees east")
    ap.add_argument("--alt-ft", type=float, help="--new-site: ground height above PASS's ellipsoid, feet")
    ap.add_argument("--delh-ft", type=float, help="--new-site: mean sea level above PASS's ellipsoid, feet (the table's DELH)")
    ap.add_argument("--naip", type=int, metavar="YEAR", help="--new-site: a US site: NAIP imagery of this year for ring 0 instead of Sentinel-2")
    ap.add_argument("--runway", action="append", metavar="LAT1,LON1,LAT2,LON2[,WIDTH_M]",
                    help="--new-site, outside the US: a runway's two thresholds, painted into the Sentinel-2 base (repeatable)")
    ap.add_argument("--keep", type=float, default=0.3, help="fraction of the colour shift toward Sentinel's means (default 0.3)")
    args = ap.parse_args()
    d = os.path.join(SITES, args.site)
    if args.new_site and not args.restore:
        ensure_site(args)
    if not os.path.exists(os.path.join(d, "ring.json")):
        sys.exit("msfs_cgl: no cache/sites/%s (run portview/fetch_assets.py --sites %s first, or give --new-site)" % (args.site, args.site))
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
    # the fine ring's pixels: the next power of two that gives the source's pixel size over +-1.5 km (4096 for
    # LEZG's 0.89 m, 8192 for 0.45 m and finer, KSC's own size), never fewer than 4096 or more than 8192
    mpp = 156543.03392 * math.cos(math.radians(lat)) / 2 ** layers[0]["z"]
    FINE_PX = int(min(8192, max(4096, 2 ** math.ceil(math.log2(2 * FINE_HALF_KM * 1000 / mpp)))))
    log("finest level LOD%d is %.2f m/px: fine ring %d px (%.2f m/px), ring 0 %d px" % (layers[0]["z"], mpp, FINE_PX, 2 * FINE_HALF_KM * 1000 / FINE_PX, RING0_PX))
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
