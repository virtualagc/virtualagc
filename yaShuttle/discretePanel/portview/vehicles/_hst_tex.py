"""Procedural textures for the Hubble models (hst.py, hst1990.py): the
thermal blankets' patchwork, the aft shroud's panels, the Equipment
Section's bay doors, the aft bulkhead's reflector strips, the solar cells.

Each is drawn in linear albedo (0-1) on a grid in metres and returned as an
sRGB PIL image; a part using one has colour 1 (the texture is its albedo).
Deterministic (fixed seeds), so a rebuild gives the same model.
"""
import math

import numpy as np

ALUMINISED = 0.62               # aluminised-Teflon blanket, as a diffuse albedo
YELLOW = (0.78, 0.52, 0.06)     # handrail and tape yellow


# ---------------------------------------------------------------- utilities
def to_image(rgb):
    """Linear albedo (h, w, 3) -> an sRGB PIL image."""
    from PIL import Image
    a = np.clip(np.asarray(rgb, float), 0.0, 1.0)
    s = np.where(a <= 0.0031308, 12.92 * a, 1.055 * np.power(a, 1 / 2.4) - 0.055)
    return Image.fromarray((s * 255 + 0.5).astype(np.uint8), "RGB")


def noise(h, w, cell, seed, octaves=4, wrap_x=True):
    """Smooth value noise, about -1..1, features ~cell pixels; tiles in x."""
    from PIL import Image
    rng = np.random.default_rng(seed)
    out = np.zeros((h, w))
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        c = max(1.0, cell / (2 ** o))
        gw, gh = max(2, int(round(w / c))), max(2, int(round(h / c)))
        g = rng.standard_normal((gh, gw)).astype(np.float32)
        if wrap_x:                              # periodic in x: pad and crop
            g = np.hstack([g, g[:, :2]])
            big = np.asarray(Image.fromarray(g, "F").resize(
                (int(round(w * (gw + 2) / gw)), h), Image.BICUBIC))[:, :w]
        else:
            big = np.asarray(Image.fromarray(g, "F").resize((w, h), Image.BICUBIC))
        out += amp * big
        tot += amp
        amp *= 0.55
    return out / tot


def stretched(h, w, cell, seed, octaves, along_v):
    """noise() with its features along_v times longer down the image (v)
    than across: blanket folds run mostly along the body."""
    from PIL import Image
    hh = max(4, int(h / along_v))
    n = noise(hh, w, cell, seed, octaves).astype(np.float32)
    return np.asarray(Image.fromarray(n, "F").resize((w, h), Image.BICUBIC))


def crumple(h, w, ppm, seed, density=28.0, along_v=0.6):
    """The height (m) of a crumpled film: many straight creases (tent-shaped
    ridges and valleys, 0.2-1 m long, fading at their ends), so that between
    them the film lies in flat facets turned this way and that -- as foil
    blankets do.  along_v: the fraction of creases running roughly down v
    (along the body).  Tiles in u."""
    rng = np.random.default_rng(seed)
    out = np.zeros((h, w), np.float32)
    n = int(density * (w / ppm) * (h / ppm))
    for _ in range(n):
        cx, cy = rng.uniform(0, w), rng.uniform(0, h)
        if rng.uniform() < along_v:
            ang = math.pi / 2 + rng.normal(0, 0.35)
        else:
            ang = rng.uniform(0, math.pi)
        L = rng.uniform(0.2, 1.0) * ppm            # crease length, px
        wd = rng.uniform(0.04, 0.15) * ppm          # half-width of its slopes, px
        a = rng.normal(0, 0.012) * (wd / ppm) / 0.08
        ext = int(L / 2 + wd) + 1
        x0, x1 = int(cx) - ext, int(cx) + ext
        y0, y1 = max(0, int(cy) - ext), min(h, int(cy) + ext)
        if y1 <= y0:
            continue
        X, Y = np.meshgrid(np.arange(x0, x1, dtype=np.float32), np.arange(y0, y1, dtype=np.float32))
        dx, dy = X - cx, Y - cy
        c, s_ = math.cos(ang), math.sin(ang)
        along = dx * c + dy * s_
        perp = -dx * s_ + dy * c
        tent = np.clip(1 - np.abs(perp) / wd, 0, None) * np.clip(1 - (2 * np.abs(along) / L) ** 2, 0, None)
        cols = np.arange(x0, x1) % w
        out[y0:y1][:, cols] += a * tent
    return out


class Canvas(object):
    """A texture in metres: width_m x height_m at px_per_m, origin top-left
    (u to the right, v down); u = 0..1 maps across, v = 0..1 down."""

    def __init__(self, width_m, height_m, px_per_m, base=(0.6, 0.6, 0.6), max_px=2048):
        self.ppm = min(px_per_m, max_px / width_m, max_px / height_m)
        self.w = int(round(width_m * self.ppm))
        self.h = int(round(height_m * self.ppm))
        self.wm, self.hm = width_m, height_m
        self.a = np.ones((self.h, self.w, 3)) * np.asarray(base, float)

    def px(self, x_m, y_m):
        return x_m * self.ppm, y_m * self.ppm

    def mask_rect(self, x0, y0, x1, y1):
        X, Y = np.meshgrid((np.arange(self.w) + 0.5) / self.ppm, (np.arange(self.h) + 0.5) / self.ppm)
        return (X >= min(x0, x1)) & (X < max(x0, x1)) & (Y >= min(y0, y1)) & (Y < max(y0, y1))

    def mask_ellipse(self, cx, cy, rx, ry, wrap=True):
        X, Y = np.meshgrid((np.arange(self.w) + 0.5) / self.ppm, (np.arange(self.h) + 0.5) / self.ppm)
        dx = X - cx
        if wrap:
            dx = (dx + self.wm / 2) % self.wm - self.wm / 2
        return (dx / rx) ** 2 + ((Y - cy) / ry) ** 2 <= 1.0

    def fill(self, mask, rgb, alpha=1.0):
        self.a[mask] = (1 - alpha) * self.a[mask] + alpha * np.asarray(rgb, float)

    def rect(self, x0, y0, x1, y1, rgb, alpha=1.0):
        self.fill(self.mask_rect(x0, y0, x1, y1), rgb, alpha)

    def hline(self, y, x0, x1, width, rgb, alpha=1.0):
        self.rect(x0, y - width / 2, x1, y + width / 2, rgb, alpha)

    def vline(self, x, y0, y1, width, rgb, alpha=1.0):
        self.rect(x - width / 2, y0, x + width / 2, y1, rgb, alpha)

    def image(self):
        return to_image(self.a)


# ------------------------------------------------------------ the blankets
def mli(cv, seed, crinkle=1.0, base=ALUMINISED, patch=(0.9, 0.6), tint=(1.0, 1.0, 1.02),
        y_range=None):
        """Aluminised blanket over cv (or rows y_range (m) of it): a patchwork
        of panels (patch: typical size, m) a little different in tone, taped
        seams, and the crinkles (crinkle 0: smooth new blanket; 1: as on
        orbit in 2009, wrinkled and sagging between its tie-downs)."""
        h, w = cv.h, cv.w
        rng = np.random.default_rng(seed)
        ppm = cv.ppm
        tone = np.zeros((h, w))
        # patchwork: columns of panels, each column cut at its own heights
        x = 0.0
        while x < cv.wm - 1e-6:
            dx = min(cv.wm - x, patch[0] * rng.uniform(0.6, 1.4))
            if cv.wm - (x + dx) < 0.25 * patch[0]:
                dx = cv.wm - x
            y = -rng.uniform(0, patch[1])
            while y < cv.hm:
                dy = patch[1] * rng.uniform(0.6, 1.6)
                i0, i1 = int(max(0, y) * ppm), int(min(cv.hm, y + dy) * ppm)
                j0, j1 = int(x * ppm), int((x + dx) * ppm)
                tone[i0:i1, j0:j1] = rng.normal(0.0, 0.06)
                # taped seams along the panel's edges
                t = max(1, int(0.025 * ppm))
                tone[i0:i0 + t, j0:j1] = 0.10
                tone[i0:i1, j0:j0 + t] = 0.10
                y += dy
            x += dx
        n1 = noise(h, w, 0.35 * ppm, seed + 1, 4)
        # crinkles: a wrinkled film's relief (a height field of stretched,
        # sharpened noise) shaded by a fixed light -- bright and dark facets
        hgt = crumple(h, w, ppm, seed + 2) + 0.012 * stretched(h, w, 0.5 * ppm, seed + 3, 2, 2.0)
        gy, gx = np.gradient(hgt)
        g = ppm
        shade = (0.6 * gx + 0.8 * gy) * g / np.sqrt(1 + (gx * g) ** 2 + (gy * g) ** 2)
        shade = np.tanh(3.0 * shade)
        a = base + tone + crinkle * (0.10 * n1 + 0.30 * shade) + (1 - crinkle) * (0.03 * n1 + 0.05 * shade)
        a = np.clip(a, 0.18, 0.92)
        rgb = a[..., None] * np.asarray(tint, float)
        if y_range is None:
            cv.a[:] = rgb
        else:
            i0, i1 = int(y_range[0] * ppm), int(y_range[1] * ppm)
            cv.a[i0:i1] = rgb[i0:i1]
        return cv


def nasa_worm(cv, cx, cy, height, rgb=(0.50, 0.03, 0.03)):
    """The NASA 'worm' logotype, about 3.6 x its height wide, centred at
    (cx, cy) m: drawn in a heavy sans face as an approximation."""
    from PIL import Image, ImageDraw, ImageFont
    hp = max(8, int(height * cv.ppm))
    font = None
    for f in ("/System/Library/Fonts/Supplemental/Arial Black.ttf",
              "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
              "/System/Library/Fonts/Helvetica.ttc",
              "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "C:/Windows/Fonts/arialbd.ttf"):
        try:
            font = ImageFont.truetype(f, int(hp * 1.3))
            break
        except (OSError, IOError):
            continue
    if font is None:
        font = ImageFont.load_default()
    # the worm's A's have no crossbars: draw 'NΛSΛ'-like with the plain A
    # (a crossbar this small is lost at any useful range anyway)
    im = Image.new("L", (hp * 6, hp * 2), 0)
    d = ImageDraw.Draw(im)
    d.text((hp // 4, hp // 4), "NASA", fill=255, font=font)
    box = im.getbbox()
    if box is None:
        return cv
    im = im.crop(box)
    wpx = int(3.6 * hp)
    im = im.resize((wpx, hp), Image.LANCZOS)
    m = np.asarray(im, float) / 255.0
    x0 = int(cx * cv.ppm - wpx / 2)
    y0 = int(cy * cv.ppm - hp / 2)
    for j in range(wpx):
        xx = (x0 + j) % cv.w
        col = m[:, j]
        ys = slice(max(0, y0), min(cv.h, y0 + hp))
        cc = col[ys.start - y0:ys.stop - y0, None]
        cv.a[ys, xx] = cv.a[ys, xx] * (1 - cc) + np.asarray(rgb) * cc
    return cv


def esa_logo(cv, cx, cy, r, rgb=(0.05, 0.08, 0.30)):
    """A small dark-blue roundel standing for the ESA logo beside the worm."""
    ring = cv.mask_ellipse(cx, cy, r, r) & ~cv.mask_ellipse(cx, cy, 0.7 * r, 0.7 * r)
    cv.fill(ring, rgb)
    cv.fill(cv.mask_ellipse(cx, cy, 0.3 * r, 0.3 * r), rgb)
    return cv


# ------------------------------------------------------------ aft shroud
def panels(cv, seed, base, grid=(0.55, 0.55), line=0.012, line_rgb=None, rivets=True, tone=0.04,
           y_range=None):
    """Stiffened skin under its reflective tape: a grid of panels with
    seams and rows of fasteners, each panel a slightly different tone."""
    rng = np.random.default_rng(seed)
    h, w = cv.h, cv.w
    ppm = cv.ppm
    base = np.asarray(base, float)
    out = np.ones((h, w, 3)) * base
    nx, ny = max(1, int(round(cv.wm / grid[0]))), max(1, int(round(cv.hm / grid[1])))
    for i in range(ny):
        for j in range(nx):
            i0, i1 = int(i * h / ny), int((i + 1) * h / ny)
            j0, j1 = int(j * w / nx), int((j + 1) * w / nx)
            out[i0:i1, j0:j1] *= 1 + rng.normal(0, tone)
    n = noise(h, w, 0.4 * ppm, seed + 5, 3)
    out *= (1 + 0.05 * n)[..., None]
    lr = np.asarray(line_rgb if line_rgb is not None else base * 0.55, float)
    t = max(1, int(line * ppm))
    for i in range(ny + 1):
        r0 = min(h - t, int(i * h / ny))
        out[r0:r0 + t] = lr
    for j in range(nx + 1):
        c0 = min(w - t, int(j * w / nx))
        out[:, c0:c0 + t] = lr
    if rivets:
        step = max(2, int(0.07 * ppm))
        rv = np.clip(base * 1.6, 0, 0.9)
        for i in range(ny + 1):
            r0 = min(h - 1, int(i * h / ny) + 2 * t)
            out[r0, ::step] = rv
        for j in range(nx + 1):
            c0 = min(w - 1, int(j * w / nx) + 2 * t)
            out[::step, c0] = rv
    if y_range is None:
        cv.a[:] = out
    else:
        i0, i1 = int(y_range[0] * ppm), int(y_range[1] * ppm)
        cv.a[i0:i1] = out[i0:i1]
    return cv


# ---------------------------------------------------- Equipment Section
def louvres(cv, x0, y0, x1, y1):
    """A radiator window of the Equipment Section's bay doors: white
    louvre blades on black, in a silver frame (as on Bays 2, 3 and 10)."""
    cv.rect(x0 - 0.03, y0 - 0.03, x1 + 0.03, y1 + 0.03, (0.70, 0.70, 0.70))
    cv.rect(x0, y0, x1, y1, (0.03, 0.03, 0.03))
    n = max(2, int((x1 - x0) / 0.075))
    for k in range(n):
        xa = x0 + (k + 0.15) * (x1 - x0) / n
        xb = x0 + (k + 0.75) * (x1 - x0) / n
        cv.rect(xa, y0 + 0.02, xb, y1 - 0.02, (0.80, 0.80, 0.80))
    cv.hline((y0 + y1) / 2, x0, x1, 0.025, (0.70, 0.70, 0.70))
    return cv


def nobl(cv, x0, y0, x1, y1, seed):
    """A New Outer Blanket Layer: a stainless-steel foil cover, brighter and
    smoother than the blankets, in ribbed strips, edged in tape."""
    rng = np.random.default_rng(seed)
    m = cv.mask_rect(x0, y0, x1, y1)
    n = noise(cv.h, cv.w, 0.2 * cv.ppm, seed, 3)
    X = (np.arange(cv.w) + 0.5) / cv.ppm
    rib = 0.04 * np.cos(2 * math.pi * X / 0.10)[None, :]
    val = 0.70 + 0.05 * n + rib + rng.normal(0, 0.01)
    cv.a[m] = np.clip(val[m], 0, 0.9)[:, None] * np.array([1.0, 1.0, 1.0])
    for x in (x0, x1):
        cv.vline(x, y0, y1, 0.04, (0.80, 0.80, 0.78))
    for y in (y0, y1):
        cv.hline(y, x0, x1, 0.04, (0.80, 0.80, 0.78))
    return cv


# ------------------------------------------------------------ aft bulkhead
def bulkhead(radius, ppm=300, seed=11):
    """The aft bulkhead seen from aft (u along +V2... as the caller maps
    it): parallel strips of silvered reflector tape over the honeycomb,
    some panels' strips dark (as photographed on STS-109)."""
    size = 2 * radius
    cv = Canvas(size, size, ppm, base=(0.42, 0.42, 0.43))
    rng = np.random.default_rng(seed)
    h = cv.h
    strip = 0.10
    ys = np.arange(0, size, strip)
    for k, y in enumerate(ys):
        v = rng.normal(0.44, 0.04)
        cv.rect(0, y, size, y + strip, (v, v, v * 1.01))
        cv.hline(y, 0, size, 0.008, (0.30, 0.30, 0.30))
    # dark runs of strips (the black stripes across the bulkhead)
    for _ in range(14):
        y = rng.choice(ys)
        x0 = rng.uniform(0, size * 0.8)
        cv.rect(x0, y + 0.01, x0 + rng.uniform(0.3, 1.2), y + strip - 0.01, (0.06, 0.06, 0.07))
    # fastener pairs
    for _ in range(60):
        x, y = rng.uniform(0, size), rng.uniform(0, size)
        cv.fill(cv.mask_ellipse(x, y, 0.025, 0.025, wrap=False), (0.80, 0.80, 0.80))
    return cv


# ------------------------------------------------------------- the arrays
def sa3_front(width_m, length_m, ppm=160):
    """SA3's sun side: the cells (dark blue-violet) in strings, with the
    panels' silver frames; u across the wing, v along it."""
    cv = Canvas(width_m, length_m, ppm, base=(0.035, 0.045, 0.11))
    n = noise(cv.h, cv.w, 0.3 * cv.ppm, 21, 3)
    cv.a *= (1 + 0.15 * n)[..., None]
    for x in np.arange(0, width_m, 0.07):          # cell gaps
        cv.vline(x, 0, length_m, 0.006, (0.10, 0.10, 0.12))
    for y in np.arange(0, length_m, 0.04):
        cv.hline(y, 0, width_m, 0.004, (0.08, 0.08, 0.10))
    return cv


def sa3_back(width_m, length_m, ppm=160, half=True):
    """SA3's back: white-painted substrate in four panels a half-wing,
    with the hinge tapes' yellow-orange dashes down the middle."""
    cv = Canvas(width_m, length_m, ppm, base=(0.74, 0.74, 0.72))
    n = noise(cv.h, cv.w, 0.4 * cv.ppm, 23, 3)
    cv.a *= (1 + 0.04 * n)[..., None]
    for x in (width_m / 2,):
        cv.vline(x, 0, length_m, 0.012, (0.45, 0.45, 0.45))
        for y in np.arange(0.1, length_m, 0.28):
            cv.rect(x - 0.10, y, x - 0.04, y + 0.12, (0.80, 0.45, 0.05))
    for y in np.linspace(0, length_m, 3):
        cv.hline(y, 0, width_m, 0.015, (0.45, 0.45, 0.45))
    return cv


def sa1_blanket(width_m, length_m, front, ppm=120):
    """SA1's flexible blankets (1990-93): the cells' backing seen from
    behind is gold-brown Kapton with the cell grid showing; the front is
    the cells, deep blue."""
    if front:
        cv = Canvas(width_m, length_m, ppm, base=(0.04, 0.05, 0.12))
        line = (0.12, 0.10, 0.08)
    else:
        cv = Canvas(width_m, length_m, ppm, base=(0.52, 0.30, 0.08))
        line = (0.70, 0.48, 0.12)
    n = noise(cv.h, cv.w, 0.5 * cv.ppm, 31 if front else 33, 3)
    cv.a *= (1 + 0.12 * n)[..., None]
    for x in np.arange(0, width_m, 0.0635):
        cv.vline(x, 0, length_m, 0.005, line, 0.6)
    for y in np.arange(0, length_m, 0.042):
        cv.hline(y, 0, width_m, 0.004, line, 0.4)
    for y in np.arange(0, length_m, 0.62):            # panel hinges
        cv.hline(y, 0, width_m, 0.02, line)
    return cv
