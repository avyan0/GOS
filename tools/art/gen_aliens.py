"""Procedural alien portraits for Gods of Space.

python tools/art/gen_aliens.py   ->  assets/img/aliens/<key>.png (256x256 RGBA) + sheet.png

Everything is drawn at 2x (512px) with Pillow + numpy and downsampled for AA.
Deterministic: every random choice comes from a per-alien seeded RNG.
"""
import colorsys
import json
import math
import os
import random

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(ROOT, "tools", "art", "src", "aliens")  # high-res source; pixelize.py makes the game assets
S = 512            # working canvas
C = S // 2         # centre
LIGHT = (-0.55, -0.75)  # upper-left

# ----------------------------------------------------------------- colour --

def hsv(h, s, v, a=255):
    r, g, b = colorsys.hsv_to_rgb(h % 1.0, max(0, min(1, s)), max(0, min(1, v)))
    return (int(r * 255), int(g * 255), int(b * 255), a)


def shade_col(col, mul, a=None):
    r, g, b = col[:3]
    a = col[3] if a is None and len(col) > 3 else (255 if a is None else a)
    return (max(0, min(255, int(r * mul))), max(0, min(255, int(g * mul))),
            max(0, min(255, int(b * mul))), a)


def mix(c1, c2, t):
    return tuple(int(c1[i] * (1 - t) + c2[i] * t) for i in range(3)) + (255,)

# ------------------------------------------------------------ primitives --

def new():
    return Image.new("RGBA", (S, S), (0, 0, 0, 0))


def mask_new():
    return Image.new("L", (S, S), 0)


def ellipse_mask(box):
    m = mask_new()
    ImageDraw.Draw(m).ellipse(box, fill=255)
    return m


def poly_mask(pts):
    m = mask_new()
    ImageDraw.Draw(m).polygon(pts, fill=255)
    return m


def rrect_mask(box, r):
    m = mask_new()
    ImageDraw.Draw(m).rounded_rectangle(box, r, fill=255)
    return m


def blur(m, r):
    return m.filter(ImageFilter.GaussianBlur(r))


def dilate(m, px):
    px = int(px)
    if px <= 0:
        return m
    return m.filter(ImageFilter.MaxFilter(px * 2 + 1))


def erode(m, px):
    px = int(px)
    if px <= 0:
        return m
    return m.filter(ImageFilter.MinFilter(px * 2 + 1))


def fill(img, m, col):
    """Paint solid colour through mask m onto img."""
    layer = Image.new("RGBA", (S, S), col[:3] + (255,))
    layer.putalpha(ImageChops.multiply(m, Image.new("L", (S, S), col[3] if len(col) > 3 else 255)))
    img.alpha_composite(layer)


def shaded(img, m, col, amount=0.45, rim=0.55, spec=0.35, ao=0.35, light=LIGHT, curve=1.0):
    """Cel/soft-shaded fill: sphere-like lighting from upper-left, edge
    occlusion, rim light on the lit edge and a specular blob."""
    a = np.asarray(m, np.float32) / 255.0
    ys, xs = np.nonzero(a > 0.02)
    if len(xs) == 0:
        return
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    gx = (np.arange(S) - (x0 + x1) / 2.0) / max(1.0, (x1 - x0) / 2.0)
    gy = (np.arange(S) - (y0 + y1) / 2.0) / max(1.0, (y1 - y0) / 2.0)
    X, Y = np.meshgrid(gx, gy)
    r2 = np.clip(X * X + Y * Y, 0, 1)
    Z = np.sqrt(1 - r2) ** curve
    lx, ly, lz = light[0], light[1], 0.7
    n = math.sqrt(lx * lx + ly * ly + lz * lz)
    lum = (X * lx + Y * ly + Z * lz) / n
    f = 1.0 + amount * lum
    inner = np.asarray(blur(m, 10), np.float32) / 255.0
    f *= (1 - ao) + ao * inner
    sp = np.exp(-(((X - light[0] * 0.75) ** 2 + (Y - light[1] * 0.7) ** 2) / 0.06))
    base = np.array(col[:3], np.float32)
    rgb = base[None, None, :] * f[:, :, None]
    rgb += spec * 255 * sp[:, :, None]
    # rim light along the lit (upper-left) edge
    shifted = np.asarray(ImageChops.offset(m, 5, 5), np.float32) / 255.0
    rimm = np.clip(a - shifted, 0, 1) * (np.clip(-(X + Y), 0, 2) / 2)
    rgb += rim * 255 * rimm[:, :, None]
    out = np.zeros((S, S, 4), np.uint8)
    out[:, :, :3] = np.clip(rgb, 0, 255)
    out[:, :, 3] = (a * (col[3] if len(col) > 3 else 255)).astype(np.uint8)
    img.alpha_composite(Image.fromarray(out, "RGBA"))


def outline(img, m, col, w=5):
    fill(img, dilate(m, w), col)


def glow(img, m, col, r=22, strength=1.0):
    g = blur(dilate(m, 4), r)
    g = g.point(lambda v: min(255, int(v * strength)))
    fill(img, g, col)


def drop_shadow(img, m, dx=6, dy=8, r=8, alpha=120):
    sh = blur(ImageChops.offset(m, dx, dy), r)
    fill(img, sh, (0, 0, 0, alpha))

# --------------------------------------------------------------- shapes ---

def body_mask(shape, cx, cy, w, h, rot=0.0):
    """Silhouette for the spec shape. w,h = half extents."""
    if shape == "round":
        return ellipse_mask((cx - w, cy - h, cx + w, cy + h))
    if shape == "square":
        return rrect_mask((cx - w, cy - h, cx + w, cy + h), min(w, h) * 0.32)
    if shape == "hex":
        pts = [(cx + w * math.cos(math.radians(60 * i + 30 + rot)),
                cy + h * math.sin(math.radians(60 * i + 30 + rot))) for i in range(6)]
        return poly_mask(pts)
    if shape == "diamond":
        return poly_mask([(cx, cy - h), (cx + w, cy), (cx, cy + h), (cx - w, cy)])
    if shape == "tri":
        return poly_mask([(cx, cy - h), (cx + w, cy + h * 0.85), (cx - w, cy + h * 0.85)])
    raise ValueError(shape)


def soften(m, r=6):
    """Round off polygon corners: blur then threshold."""
    return blur(m, r).point(lambda v: 255 if v > 127 else 0)


def spikes_mask(cx, cy, rx, ry, n, length, width=0.5, a0=-90, span=360, jitter=None):
    """Triangular spikes on an ellipse rim. Returns L mask."""
    m = mask_new()
    d = ImageDraw.Draw(m)
    for i in range(n):
        a = math.radians(a0 + span * i / max(1, n - (0 if span == 360 else 1)))
        ln = length * (1 + (jitter.uniform(-0.25, 0.25) if jitter else 0))
        bx, by = cx + rx * math.cos(a), cy + ry * math.sin(a)
        tx, ty = cx + (rx + ln) * math.cos(a), cy + (ry + ln) * math.sin(a)
        px, py = -math.sin(a) * ln * width, math.cos(a) * ln * width
        d.polygon([(bx + px, by + py), (bx - px, by - py), (tx, ty)], fill=255)
    return m


def crescent_horn(cx, cy, size, flip=1, tilt=0.0):
    """Curved horn mask growing up and outward from (cx,cy)."""
    m = mask_new()
    d = ImageDraw.Draw(m)
    pts = []
    for t in np.linspace(0, 1, 14):
        ang = math.radians(-90 + tilt + flip * 70 * t)
        r = size * (1 - 0.15 * t)
        pts.append((cx + flip * size * 0.15 + r * math.cos(ang) * 0.9, cy + r * math.sin(ang)))
    base_w = size * 0.32
    outer = [(x + flip * base_w * (1 - t) * 0.8, y) for (x, y), t in zip(pts, np.linspace(0, 1, 14))]
    d.polygon([(cx - flip * base_w, cy)] + pts + outer[::-1], fill=255)
    return m

# ------------------------------------------------------------- features ---

def eye(img, cx, cy, r, iris, look=(0.15, 0.1), lid=None, lid_col=None, slit=False,
        sclera=(245, 240, 225, 255), glow_col=None, ry=None):
    """Shaded eyeball with iris gradient, pupil and highlights.
    lid: 'angry' | 'sleepy' | None. glow_col: emissive iris (no sclera)."""
    ry = ry or r
    if glow_col:
        glow(img, ellipse_mask((cx - r, cy - ry, cx + r, cy + ry)), glow_col, r=int(r * 0.6))
    m = ellipse_mask((cx - r, cy - ry, cx + r, cy + ry))
    outline(img, m, (20, 16, 28, 255), max(2, int(r * 0.12)))
    shaded(img, m, sclera if not glow_col else glow_col, amount=0.3, spec=0.15, rim=0.3)
    ir = r * 0.58
    ix, iy = cx + look[0] * r * 0.9, cy + look[1] * ry * 0.9
    im = ellipse_mask((ix - ir, iy - ir, ix + ir, iy + ir))
    im = ImageChops.multiply(im, m)
    shaded(img, im, iris, amount=0.5, spec=0.0, rim=0.0, ao=0.6)
    pr = ir * 0.5
    if slit:
        pm = ellipse_mask((ix - pr * 0.35, iy - ir * 0.85, ix + pr * 0.35, iy + ir * 0.85))
    else:
        pm = ellipse_mask((ix - pr, iy - pr, ix + pr, iy + pr))
    fill(img, ImageChops.multiply(pm, m), (10, 8, 14, 255))
    hx, hy = ix - ir * 0.35, iy - ir * 0.4
    fill(img, ImageChops.multiply(ellipse_mask((hx - ir * 0.28, hy - ir * 0.28, hx + ir * 0.28, hy + ir * 0.28)), m),
         (255, 255, 255, 235))
    hx2, hy2 = ix + ir * 0.3, iy + ir * 0.35
    fill(img, ImageChops.multiply(ellipse_mask((hx2 - ir * 0.13, hy2 - ir * 0.13, hx2 + ir * 0.13, hy2 + ir * 0.13)), m),
         (255, 255, 255, 150))
    if lid:
        lc = lid_col or (30, 24, 40, 255)
        lm = mask_new()
        d = ImageDraw.Draw(lm)
        side = 1 if cx >= C else -1
        if lid == "angry":
            inner_y, outer_y = cy - ry * 0.15, cy - ry * 0.95
            ly_l = inner_y if side > 0 else outer_y   # left edge of lid
            ly_r = outer_y if side > 0 else inner_y   # right edge of lid
            d.polygon([(cx - r * 1.3, cy - ry * 1.3), (cx + r * 1.3, cy - ry * 1.3),
                       (cx + r * 1.3, ly_r), (cx - r * 1.3, ly_l)], fill=255)
        else:  # sleepy / heavy lid
            d.rectangle((cx - r * 1.3, cy - ry * 1.3, cx + r * 1.3, cy - ry * 0.35), fill=255)
        lm = ImageChops.multiply(lm, dilate(m, 1))
        fill(img, lm, lc)
        fill(img, ImageChops.subtract(lm, erode(lm, 3)), (15, 10, 20, 255))


def eyes_row(img, n, cx, cy, spread, r, iris, **kw):
    """n eyes in a row centred on cx; 3 -> middle one bigger; 4 -> two rows."""
    if n == 1:
        eye(img, cx, cy, r * 1.6, iris, **kw)
    elif n == 2:
        eye(img, cx - spread, cy, r, iris, **kw)
        eye(img, cx + spread, cy, r, iris, **kw)
    elif n == 3:
        eye(img, cx - spread * 1.15, cy + r * 0.25, r * 0.8, iris, **kw)
        eye(img, cx + spread * 1.15, cy + r * 0.25, r * 0.8, iris, **kw)
        eye(img, cx, cy - r * 0.35, r * 1.1, iris, **kw)
    else:
        eye(img, cx - spread, cy - r * 0.6, r * 0.9, iris, **kw)
        eye(img, cx + spread, cy - r * 0.6, r * 0.9, iris, **kw)
        eye(img, cx - spread * 0.5, cy + r * 1.2, r * 0.6, iris, **kw)
        eye(img, cx + spread * 0.5, cy + r * 1.2, r * 0.6, iris, **kw)


def mouth(img, cx, cy, w, h, kind="grin", teeth=6, col=(40, 8, 20, 255), tooth_col=(240, 236, 220, 255)):
    """kind: grin (wide toothy), frown, small, fangs, zigzag, beak."""
    m = mask_new()
    d = ImageDraw.Draw(m)
    if kind == "grin":
        d.chord((cx - w, cy - h * 1.6, cx + w, cy + h * 0.6), 0, 180, fill=255)
    elif kind == "frown":
        d.chord((cx - w, cy - h * 0.6, cx + w, cy + h * 1.6), 180, 360, fill=255)
    elif kind == "small":
        d.ellipse((cx - w * 0.5, cy - h * 0.5, cx + w * 0.5, cy + h * 0.5), fill=255)
    elif kind == "zigzag":
        pts = [(cx - w, cy - h * 0.5)]
        for i in range(teeth):
            pts.append((cx - w + (i + 0.5) * 2 * w / teeth, cy + h * 0.6))
            pts.append((cx - w + (i + 1) * 2 * w / teeth, cy - h * 0.5))
        pts += [(cx + w, cy + h * 0.5), (cx - w, cy + h * 0.5)]
        d.polygon(pts, fill=255)
    elif kind == "beak":
        d.polygon([(cx - w * 0.6, cy - h * 0.4), (cx + w * 0.6, cy - h * 0.4), (cx, cy + h * 1.2)], fill=255)
    elif kind == "fangs":
        d.chord((cx - w, cy - h * 1.6, cx + w, cy + h * 0.6), 0, 180, fill=255)
    outline(img, m, (15, 8, 14, 255), 3)
    shaded(img, m, col, amount=0.3, spec=0.0, rim=0.0, ao=0.6)
    if kind in ("grin", "fangs") and teeth:
        tm = mask_new()
        d = ImageDraw.Draw(tm)
        n = teeth if kind == "grin" else 2
        for i in range(n):
            if kind == "grin":
                tx = cx - w * 0.8 + (i + 0.5) * 1.6 * w / n
                tw = 0.7 * w / n
                d.polygon([(tx - tw, cy - h * 0.05), (tx + tw, cy - h * 0.05), (tx, cy + h * 0.55)], fill=255)
            else:
                tx = cx - w * 0.5 if i == 0 else cx + w * 0.5
                d.polygon([(tx - w * 0.18, cy - h * 0.1), (tx + w * 0.18, cy - h * 0.1), (tx, cy + h * 0.9)], fill=255)
        tm = ImageChops.multiply(tm, dilate(m, 2))
        shaded(img, tm, tooth_col, amount=0.3, spec=0.0, rim=0.0, ao=0.3)
    elif kind == "beak":
        fill(img, ImageChops.multiply(ImageChops.offset(m, -3, -3), m), (255, 255, 255, 40))


def limb(img, pts, w0, w1, col, dark, segs=12):
    """Tapered limb along a polyline (list of points), shaded, outlined."""
    m = mask_new()
    d = ImageDraw.Draw(m)
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    n = len(pts)
    prev = None
    for i in range(segs + 1):
        t = i / segs
        # Catmull-like smoothing via simple quadratic bezier through first/mid/last
        if n == 3:
            x = (1 - t) ** 2 * xs[0] + 2 * (1 - t) * t * xs[1] + t * t * xs[2]
            y = (1 - t) ** 2 * ys[0] + 2 * (1 - t) * t * ys[1] + t * t * ys[2]
        else:
            k = t * (n - 1)
            i0 = min(n - 2, int(k))
            f = k - i0
            x = xs[i0] * (1 - f) + xs[i0 + 1] * f
            y = ys[i0] * (1 - f) + ys[i0 + 1] * f
        r = w0 * (1 - t) + w1 * t
        d.ellipse((x - r, y - r, x + r, y + r), fill=255)
        if prev:
            d.line([prev, (x, y)], fill=255, width=int(2 * r))
        prev = (x, y)
    outline(img, m, dark, 4)
    shaded(img, m, col, amount=0.4, spec=0.15, rim=0.4, ao=0.5)
    return m


def tentacles(img, cx, cy, n, length, w, col, dark, rng, spread=1.0, base_w=None):
    for i in range(n):
        t = (i - (n - 1) / 2) / max(1, (n - 1) / 2)
        x0 = cx + t * w * spread
        x1 = x0 + t * w * 0.6 + rng.uniform(-14, 14)
        x2 = x0 + t * w * 1.1 + rng.uniform(-24, 24)
        limb(img, [(x0, cy), (x1, cy + length * 0.55), (x2, cy + length)],
             base_w or w * 0.16, w * 0.05, col, dark)


def arms(img, cx, cy, w, col, dark, up=False, width=18, claws=True):
    for s in (-1, 1):
        ex = cx + s * w * 1.5
        ey = cy - w * 0.55 if up else cy + w * 0.45
        limb(img, [(cx + s * w * 0.6, cy), (cx + s * w * 1.2, cy + (0 if up else w * 0.3)), (ex, ey)],
             width, width * 0.7, col, dark)
        if claws:
            for k in range(3):
                a = (-100 if up else -20) + s * 0 + (k - 1) * 32 * (-1 if up else 1)
                a = math.radians(a if s > 0 else 180 - a)
                claw = poly_mask([(ex - 7, ey), (ex + 7, ey), (ex + math.cos(a) * width * 1.4, ey + math.sin(a) * width * 1.4)])
                outline(img, claw, dark, 3)
                fill(img, claw, (232, 226, 210, 255))


def legs(img, cx, cy, w, col, dark, n=2, width=16):
    for i in range(n):
        t = (i - (n - 1) / 2) / max(1, (n - 1) / 2) if n > 1 else 0
        x = cx + t * w * 0.7
        limb(img, [(x, cy), (x + t * w * 0.15, cy + 40), (x + t * w * 0.35, cy + 68)], width, width * 0.9, col, dark)
        foot = ellipse_mask((x + t * w * 0.35 - width * 1.3, cy + 58, x + t * w * 0.35 + width * 1.3, cy + 80))
        outline(img, foot, dark, 3)
        shaded(img, foot, shade_col(col, 0.85), amount=0.3, spec=0.1)


def antennae(img, cx, cy, col, dark, n=2, length=90, bulb=True, bulb_col=None, spread=45):
    for i in range(n):
        s = (i - (n - 1) / 2) / max(0.5, (n - 1) / 2)
        x1 = cx + s * spread
        tip = (cx + s * spread * 1.8, cy - length)
        limb(img, [(x1, cy), (cx + s * spread * 1.5, cy - length * 0.55), tip], 7, 5, col, dark)
        if bulb:
            bm = ellipse_mask((tip[0] - 13, tip[1] - 13, tip[0] + 13, tip[1] + 13))
            bc = bulb_col or hsv(0.5, 0.6, 1.0)
            glow(img, bm, bc, 14)
            outline(img, bm, dark, 3)
            shaded(img, bm, bc, amount=0.4, spec=0.5)

# ------------------------------------------------------------- textures ---

def texture(img, bm, kind, col, dark, rng, box):
    """Overlay a surface texture clipped to body mask bm. box = (x0,y0,x1,y1)."""
    x0, y0, x1, y1 = box
    t = mask_new()
    d = ImageDraw.Draw(t)
    inner = erode(bm, 6)
    if kind == "scales":
        r = 20
        row = 0
        y = y0
        while y < y1 + r:
            off = r if row % 2 else 0
            x = x0 - r + off
            while x < x1 + r:
                d.arc((x - r, y - r, x + r, y + r * 0.9), 0, 180, fill=255, width=4)
                x += 2 * r
            y += r * 0.7
            row += 1
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.0, 110))
    elif kind == "plates":
        step = 46
        y = y0 + step * 0.6
        while y < y1:
            d.line([(x0, y), (x1, y + 6)], fill=255, width=5)
            y += step
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.0, 170))
        t2 = mask_new()
        d2 = ImageDraw.Draw(t2)
        y = y0 + step * 0.6
        while y < y1:
            for x in range(int(x0) + 20, int(x1), 44):
                d2.ellipse((x - 5, y - 16, x + 5, y - 6), fill=255)
            y += step
        fill(img, ImageChops.multiply(t2, inner), shade_col(col, 1.35, 200))
    elif kind == "slime":
        for _ in range(9):
            x = rng.uniform(x0, x1)
            y = rng.uniform(y0, y1)
            r = rng.uniform(8, 22)
            d.ellipse((x - r, y - r * 0.7, x + r, y + r * 0.7), fill=255)
        t = blur(t, 3)
        fill(img, ImageChops.multiply(t, inner), shade_col(col, 1.4, 120))
        # drips on the lower edge
        dm = mask_new()
        dd = ImageDraw.Draw(dm)
        for i in range(4):
            x = x0 + (x1 - x0) * (0.2 + 0.2 * i) + rng.uniform(-8, 8)
            ln = rng.uniform(16, 40)
            dd.rounded_rectangle((x - 7, y1 - 14, x + 7, y1 + ln), 7, fill=255)
        dm = ImageChops.subtract(dm, bm)
        outline(img, dm, dark, 3)
        shaded(img, dm, col, amount=0.4, spec=0.4)
    elif kind == "metal":
        for i in range(3):
            y = y0 + (y1 - y0) * (0.25 + 0.25 * i)
            d.line([(x0, y), (x1, y)], fill=255, width=4)
        d.line([(x0 + (x1 - x0) * 0.5, y0), (x0 + (x1 - x0) * 0.5, y1)], fill=255, width=4)
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.0, 200))
        # specular streak
        s = mask_new()
        ImageDraw.Draw(s).polygon([(x0 + 10, y0 + 40), (x0 + 60, y0 + 10), (x0 + 120, y0 + 10), (x0 + 60, y0 + 60)], fill=255)
        fill(img, ImageChops.multiply(blur(s, 4), inner), (255, 255, 255, 90))
    elif kind == "spots":
        for _ in range(14):
            x = rng.uniform(x0, x1)
            y = rng.uniform(y0, y1)
            r = rng.uniform(5, 14)
            d.ellipse((x - r, y - r, x + r, y + r), fill=255)
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.3, 120))
    elif kind == "cracks":
        for _ in range(7):
            x = rng.uniform(x0, x1)
            y = rng.uniform(y0, y1)
            pts = [(x, y)]
            for _ in range(4):
                x += rng.uniform(-30, 30)
                y += rng.uniform(-30, 30)
                pts.append((x, y))
            d.line(pts, fill=255, width=4)
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.0, 180))
    elif kind == "veins":
        for _ in range(10):
            x = rng.uniform(x0, x1)
            y = rng.uniform(y0, y1)
            pts = [(x, y)]
            for _ in range(5):
                x += rng.uniform(-24, 24)
                y += rng.uniform(-24, 24)
                pts.append((x, y))
            d.line(pts, fill=255, width=3)
        fill(img, ImageChops.multiply(blur(t, 1), inner), shade_col(col, 1.5, 120))
    elif kind == "cloth":
        for i in range(-10, 12):
            d.line([(x0 + i * 26, y0), (x0 + i * 26 + 60, y1)], fill=255, width=3)
        fill(img, ImageChops.multiply(t, inner), shade_col(dark, 1.0, 60))

# ---------------------------------------------------------- accessories ---

GOLD = (255, 209, 102, 255)
GOLD_D = (120, 80, 20, 255)
RED = (235, 40, 60, 255)
RED_D = (70, 8, 20, 255)


def crown(img, cx, cy, w, h=44, points=5, col=GOLD, big=False):
    m = mask_new()
    d = ImageDraw.Draw(m)
    pts = [(cx - w, cy + h * 0.55)]
    for i in range(points):
        pts.append((cx - w + (i + 0.5) * 2 * w / points, cy - h * (1.0 if i % 2 == 0 or big else 0.5)))
        pts.append((cx - w + (i + 1) * 2 * w / points, cy + h * 0.1))
    pts[-1] = (cx + w, cy + h * 0.55)
    d.polygon(pts, fill=255)
    d.rounded_rectangle((cx - w, cy, cx + w, cy + h * 0.55), 6, fill=255)
    outline(img, m, GOLD_D, 4)
    shaded(img, m, col, amount=0.4, spec=0.5, rim=0.6, ao=0.4)
    for i in range(points):
        x = cx - w + (i + 0.5) * 2 * w / points
        gm = ellipse_mask((x - 7, cy - h - 6, x + 7, cy - h + 8)) if i % 2 == 0 or big else None
        if gm:
            fill(img, gm, RED if i % 4 == 0 else hsv(0.55, 0.8, 1.0))
    gm = ellipse_mask((cx - 9, cy + h * 0.1, cx + 9, cy + h * 0.5))
    outline(img, gm, GOLD_D, 2)
    shaded(img, gm, RED, amount=0.5, spec=0.6)


def horns(img, cx, cy, size, dark, col=(70, 20, 30, 255), tilt=0.0):
    for s in (-1, 1):
        m = crescent_horn(cx + s * size * 0.55, cy, size, s, tilt)
        outline(img, m, dark, 4)
        shaded(img, m, col, amount=0.5, spec=0.3, rim=0.5)
        tip = erode(m, int(size * 0.25))
        fill(img, ImageChops.subtract(m, dilate(tip, int(size * 0.08))), (0, 0, 0, 0))


def aura_ring(img, cx, cy, r, col, dark_col=(20, 2, 8, 255), width=14):
    """Flat ominous halo on the ground behind the body."""
    outer = ellipse_mask((cx - r, cy - r * 0.32, cx + r, cy + r * 0.32))
    inner = erode(outer, width)
    ring = ImageChops.subtract(outer, inner)
    fill(img, blur(dilate(ring, 12), 14), shade_col(col, 1.0, 140))
    fill(img, dilate(ring, 3), dark_col)
    fill(img, ring, col)
    fill(img, ImageChops.subtract(ring, ImageChops.offset(ring, 5, 5)), (255, 255, 255, 110))


def energy_aura(img, bm, col, r=34):
    fill(img, blur(dilate(bm, 20), r), shade_col(col, 1.0, 150))
    fill(img, blur(dilate(bm, 8), 8), shade_col(col, 1.2, 160))


def hev_spikes(img, cx, cy, rx, ry, rng, dark, n=10, length=34):
    m = spikes_mask(cx, cy, rx, ry, n, length, 0.45, -150, 300, rng)
    outline(img, m, dark, 4)
    shaded(img, m, RED, amount=0.5, spec=0.3)
    return m


def star_mask(cx, cy, r, n=5, inner=0.45):
    pts = []
    for i in range(2 * n):
        rr = r if i % 2 == 0 else r * inner
        a = math.radians(-90 + 180 * i / n)
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return poly_mask(pts)


def skull(img, cx, cy, r, col=(228, 222, 205, 255), dark=(40, 30, 40, 255)):
    m = ellipse_mask((cx - r, cy - r, cx + r, cy + r * 0.8))
    jaw = rrect_mask((cx - r * 0.6, cy + r * 0.2, cx + r * 0.6, cy + r * 1.05), r * 0.2)
    m = ImageChops.lighter(m, jaw)
    outline(img, m, dark, 4)
    shaded(img, m, col, amount=0.4, spec=0.2)
    for s in (-1, 1):
        fill(img, ellipse_mask((cx + s * r * 0.45 - r * 0.28, cy - r * 0.3, cx + s * r * 0.45 + r * 0.28, cy + r * 0.25)), dark)
    fill(img, poly_mask([(cx, cy + r * 0.2), (cx - r * 0.12, cy + r * 0.5), (cx + r * 0.12, cy + r * 0.5)]), dark)
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(4):
        x = cx - r * 0.45 + i * r * 0.3
        d.line([(x, cy + r * 0.62), (x, cy + r * 1.0)], fill=255, width=3)
    fill(img, t, dark)


def shield(img, cx, cy, w, h, col, dark, emblem=None):
    m = mask_new()
    d = ImageDraw.Draw(m)
    d.polygon([(cx - w, cy - h), (cx + w, cy - h), (cx + w, cy + h * 0.2), (cx, cy + h), (cx - w, cy + h * 0.2)], fill=255)
    m = soften(m, 5)
    outline(img, m, dark, 5)
    shaded(img, m, col, amount=0.4, spec=0.4, rim=0.5)
    rim_m = ImageChops.subtract(m, erode(m, 10))
    fill(img, rim_m, shade_col(col, 0.6, 200))
    if emblem == "cross":
        fill(img, rrect_mask((cx - w * 0.15, cy - h * 0.55, cx + w * 0.15, cy + h * 0.45), 4), (250, 245, 240, 255))
        fill(img, rrect_mask((cx - w * 0.55, cy - h * 0.15, cx + w * 0.55, cy + h * 0.15), 4), (250, 245, 240, 255))
    elif emblem == "star":
        fill(img, star_mask(cx, cy, w * 0.5), GOLD)
    return m

# -------------------------------------------------------------- compose ---

class Ctx:
    def __init__(self, **kw):
        self.__dict__.update(kw)


def clamp(v, lo=0.0, hi=1.0):
    return max(lo, min(hi, v))


def text_mask(txt, size, cx, cy):
    m = mask_new()
    d = ImageDraw.Draw(m)
    try:
        f = ImageFont.truetype("arialbd.ttf", size)
    except OSError:
        f = ImageFont.load_default()
    bb = d.textbbox((0, 0), txt, font=f)
    d.text((cx - (bb[2] - bb[0]) / 2 - bb[0], cy - (bb[3] - bb[1]) / 2 - bb[1]), txt, font=f, fill=255)
    return m


def fit(img, target=256, frac=0.82):
    """Crop to content, scale to fill `frac` of target, centre."""
    bb = img.getbbox()
    if not bb:
        return img.resize((target, target), Image.LANCZOS)
    crop = img.crop(bb)
    w, h = crop.size
    s = (target * frac) / max(w, h)
    crop = crop.resize((max(1, int(w * s)), max(1, int(h * s))), Image.LANCZOS)
    out = Image.new("RGBA", (target, target), (0, 0, 0, 0))
    out.alpha_composite(crop, ((target - crop.width) // 2, (target - crop.height) // 2))
    return out


def build(al):
    key = al["key"]
    spec = al["spec"]
    R = RECIPES.get(key, {})
    rng = random.Random(key)
    shape = spec["shape"]
    hue = spec["hue"]
    sat = spec.get("sat", 0.8)
    hev = al["hevalten"]
    bulk = clamp((math.log(al["health"]) - math.log(400)) / (math.log(60000) - math.log(400)))
    col = R.get("col") or hsv(hue, sat, 0.92 - 0.18 * bulk)
    dark = hsv(hue, min(1, sat + 0.1), 0.13)
    img = new()
    bw = 150 * R.get("bw", 1.0)
    bh = 150 * R.get("bh", 1.0)
    cx, cy = C, C + R.get("dy", 0)
    if "body" in R:
        bm = R["body"](cx, cy, bw, bh)
    else:
        bm = body_mask(shape, cx, cy, bw, bh)
        if shape in ("hex", "diamond", "tri"):
            bm = soften(bm, 7)
    k = Ctx(img=img, cx=cx, cy=cy, bw=bw, bh=bh, col=col, dark=dark, rng=rng, bm=bm,
            hue=hue, sat=sat, bulk=bulk, hev=hev, shape=shape, spec=spec, R=R)
    k.box = (cx - bw, cy - bh, cx + bw, cy + bh)

    # --- behind the body
    if spec.get("aura"):
        energy_aura(img, bm, RED if hev else hsv(hue + 0.08, 0.9, 1.0))
    if hev and R.get("ring", True):
        aura_ring(img, cx, cy + bh * 0.8, bw * 1.45, RED)
    if hev and R.get("horns", True):
        horns(img, cx, cy - bh * 0.8, bw * 0.62, dark, col=RED_D if bulk > 0.5 else (60, 15, 25, 255))
    if hev and R.get("spikes", True):
        hev_spikes(img, cx, cy, bw * 0.95, bh * 0.95, rng, dark, n=R.get("nspikes", 9), length=bw * 0.22)
    if "back" in R:
        R["back"](k)
    limbs = R.get("limbs", [])
    for kind, *args in limbs:
        if kind == "tentacles":
            tentacles(img, cx, cy + bh * 0.55, args[0], bh * 0.75, bw * 0.75, col, dark, rng)
        elif kind == "legs":
            legs(img, cx, cy + bh * 0.7, bw, col, dark, n=args[0] if args else 2, width=14 + 10 * bulk)
        elif kind == "arms":
            arms(img, cx, cy, bw * 0.9, col, dark, up=(args[0] if args else False), width=16 + 12 * bulk)
        elif kind == "antennae":
            antennae(img, cx, cy - bh * 0.8, col, dark, n=args[0] if args else 2,
                     bulb_col=hsv(hue + 0.5, 0.7, 1.0))

    # --- body
    drop_shadow(img, bm)
    outline(img, bm, dark, 6)
    alpha = R.get("alpha", 255)
    shaded(img, bm, col[:3] + (alpha,), amount=0.45, spec=R.get("spec", 0.35), rim=0.6, ao=0.35)
    tex = R.get("texture")
    if tex:
        texture(img, bm, tex, col, dark, rng, k.box)
    if bulk > 0.55 and R.get("armor", True):
        # chest plate band for heavy aliens
        pm = ImageChops.multiply(bm, rrect_mask((cx - bw, cy + bh * 0.6, cx + bw, cy + bh * 1.05), 30))
        pm = erode(pm, 8)
        outline(img, pm, dark, 3)
        shaded(img, pm, shade_col(col, 0.75), amount=0.4, spec=0.3, rim=0.4)
        fill(img, ImageChops.subtract(pm, ImageChops.offset(pm, 0, 4)), (255, 255, 255, 60))

    # --- face
    if R.get("eyes", True):
        n = int(spec["eyes"])
        ey = cy - bh * (0.15 if shape != "tri" else -0.05)
        er = bw * (0.19 if n < 3 else 0.17) * R.get("eye_scale", 1.0)
        spread = bw * (0.38 if shape != "tri" else 0.28)
        e = R.get("eye", {})
        eyes_row(img, n, cx + R.get("eye_dx", 0), ey + R.get("eye_dy", 0), spread, er,
                 e.get("iris", hsv(hue + 0.5, 0.85, 0.9)),
                 lid=e.get("lid", "angry" if (hev or bulk > 0.6) else None), lid_col=dark,
                 slit=e.get("slit", hev), glow_col=e.get("glow"), sclera=e.get("sclera", (245, 240, 225, 255)))
    if R.get("mouth", True):
        mk = R.get("mouth_kind", "grin" if (hev or bulk > 0.4) else "small")
        mouth(img, cx, cy + bh * 0.36 + R.get("mouth_dy", 0), bw * 0.42, bh * 0.14, mk, teeth=R.get("teeth", 6))
    if "front" in R:
        R["front"](k)
    if spec.get("crown"):
        crown(img, cx, cy - bh * 0.92, bw * 0.55, h=bh * 0.3, big=bulk > 0.8)
    return fit(img)

# -------------------------------------------------------------- recipes ---
# Each entry tweaks the shared pipeline; back()/front() draw the one detail
# that expresses the description. Keys mirror data.json.

WHITE = (245, 242, 235, 255)
INK = (24, 20, 30, 255)


def _chunk(img, m, col, dark, w=4, **kw):
    outline(img, m, dark, w)
    shaded(img, m, col, **kw)


def gen57_front(k):
    fill(k.img, text_mask("57", 74, k.cx, k.cy + k.bh * 0.05), shade_col(k.dark, 1.0, 200))
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(9):  # barcode
        d.rectangle((k.cx - 60 + i * 14, k.cy + k.bh * 0.62, k.cx - 60 + i * 14 + (4 if i % 3 else 8), k.cy + k.bh * 0.8), fill=255)
    fill(k.img, ImageChops.multiply(t, k.bm), k.dark)


def president_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # white collar + red tie
    for s in (-1, 1):
        _chunk(img, poly_mask([(cx + s * 10, cy + bh * 0.55), (cx + s * 60, cy + bh * 0.62), (cx + s * 22, cy + bh * 0.95)]), WHITE, INK, 3, amount=0.2)
    _chunk(img, poly_mask([(cx - 12, cy + bh * 0.58), (cx + 12, cy + bh * 0.58), (cx + 16, cy + bh * 0.95), (cx, cy + bh * 1.05), (cx - 16, cy + bh * 0.95)]), RED, RED_D, 3, amount=0.3)
    # flag pin
    _chunk(img, rrect_mask((cx + 48, cy + bh * 0.5, cx + 74, cy + bh * 0.62), 2), hsv(0.62, 0.8, 0.9), INK, 2)
    # hairpiece
    hm = ImageChops.multiply(ellipse_mask((cx - bw * 0.7, cy - bh * 1.05, cx + bw * 0.7, cy - bh * 0.45)), dilate(k.bm, 2))
    _chunk(img, hm, (150, 140, 130, 255), INK, 3, amount=0.3)


def king_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    cape = soften(poly_mask([(cx - bw * 0.8, cy - bh * 0.6), (cx + bw * 0.8, cy - bh * 0.6), (cx + bw * 1.45, cy + bh * 1.2), (cx - bw * 1.45, cy + bh * 1.2)]), 8)
    _chunk(img, cape, hsv(0.98, 0.85, 0.7), RED_D, 5, amount=0.4, spec=0.1)
    texture(img, cape, "cloth", hsv(0.98, 0.85, 0.7), RED_D, k.rng, (cx - bw * 1.5, cy - bh * 0.6, cx + bw * 1.5, cy + bh * 1.2))


def king_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # ermine collar with black spots
    cm = ImageChops.multiply(rrect_mask((cx - bw, cy + bh * 0.55, cx + bw, cy + bh * 1.2), 30), dilate(k.bm, 4))
    _chunk(img, cm, WHITE, INK, 4, amount=0.25)
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(7):
        d.ellipse((cx - bw * 0.8 + i * bw * 0.27, cy + bh * 0.7, cx - bw * 0.8 + i * bw * 0.27 + 12, cy + bh * 0.7 + 18), fill=255)
    fill(img, ImageChops.multiply(t, cm), INK)
    # medallion
    _chunk(img, ellipse_mask((cx - 22, cy + bh * 0.72, cx + 22, cy + bh * 1.02)), GOLD, GOLD_D, 3, spec=0.5)
    fill(img, star_mask(cx, cy + bh * 0.87, 12), RED)


def dj_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    band = ImageChops.subtract(ellipse_mask((cx - bw * 1.05, cy - bh * 1.12, cx + bw * 1.05, cy + bh * 0.9)),
                               ellipse_mask((cx - bw * 0.92, cy - bh * 0.98, cx + bw * 0.92, cy + bh * 0.9)))
    band = ImageChops.multiply(band, rrect_mask((0, 0, S, cy - bh * 0.1), 0))
    _chunk(img, band, (40, 40, 50, 255), INK, 4, amount=0.3)
    for s in (-1, 1):
        cup = ellipse_mask((cx + s * bw * 1.05 - 34, cy - bh * 0.35, cx + s * bw * 1.05 + 34, cy + bh * 0.25))
        _chunk(img, cup, (50, 50, 62, 255), INK, 4, spec=0.4)
        fill(img, ellipse_mask((cx + s * bw * 1.05 - 18, cy - bh * 0.2, cx + s * bw * 1.05 + 18, cy + bh * 0.1)), hsv(k.hue, 0.9, 1.0))
    # sound waves
    for i in range(3):
        for s in (-1, 1):
            r = bw * (1.35 + 0.22 * i)
            a = mask_new()
            ImageDraw.Draw(a).arc((cx - r, cy - r * 0.55, cx + r, cy + r * 0.55), 300 if s > 0 else 120, 60 if s > 0 else 240, fill=255, width=7)
            a = ImageChops.subtract(a, dilate(k.bm, 8))
            glow(img, a, hsv(k.hue, 0.9, 1.0), 8)
            fill(img, a, hsv(k.hue, 0.5, 1.0, 230 - 60 * i))
    # spinning record
    rec = ellipse_mask((cx - 44, cy + bh * 0.55, cx + 44, cy + bh * 1.15))
    _chunk(img, rec, (28, 26, 34, 255), INK, 3, spec=0.5)
    fill(img, ellipse_mask((cx - 16, cy + bh * 0.74, cx + 16, cy + bh * 0.96)), hsv(k.hue, 0.9, 1.0))


def fence_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    hx = soften(body_mask("hex", cx, cy, bw * 1.45, bh * 1.45, rot=0), 4)
    ring = ImageChops.subtract(hx, erode(hx, 9))
    glow(img, ring, hsv(0.5, 0.8, 1.0), 16)
    fill(img, hx, hsv(0.5, 0.7, 1.0, 45))
    fill(img, ring, hsv(0.5, 0.35, 1.0, 230))


def fence_front(k):
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(5):
        x = k.cx - k.bw * 0.7 + i * k.bw * 0.35
        d.rounded_rectangle((x - 8, k.cy + k.bh * 0.1, x + 8, k.cy + k.bh * 0.95), 6, fill=255)
    d.rounded_rectangle((k.cx - k.bw * 0.85, k.cy + k.bh * 0.35, k.cx + k.bw * 0.85, k.cy + k.bh * 0.5), 4, fill=255)
    t = ImageChops.multiply(t, k.bm)
    _chunk(k.img, t, shade_col(k.col, 0.6), k.dark, 3, amount=0.3)


def saucer_body(cx, cy, bw, bh):
    hull = ellipse_mask((cx - bw * 1.3, cy - bh * 0.1, cx + bw * 1.3, cy + bh * 0.6))
    dome = ellipse_mask((cx - bw * 0.62, cy - bh * 0.85, cx + bw * 0.62, cy + bh * 0.25))
    return ImageChops.lighter(hull, dome)


def saucer_back(k):
    # engine glow under hull
    m = ellipse_mask((k.cx - k.bw * 0.9, k.cy + k.bh * 0.35, k.cx + k.bw * 0.9, k.cy + k.bh * 0.95))
    glow(k.img, m, hsv(0.5, 0.8, 1.0), 26, 1.2)
    fill(k.img, m, hsv(0.5, 0.5, 1.0, 120))
    for s in (-1, 1):  # stubby fins
        _chunk(k.img, poly_mask([(k.cx + s * k.bw * 0.9, k.cy + k.bh * 0.15), (k.cx + s * k.bw * 1.4, k.cy - k.bh * 0.35), (k.cx + s * k.bw * 1.2, k.cy + k.bh * 0.4)]), shade_col(k.col, 0.75), k.dark)


def saucer_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    rim = ImageChops.multiply(rrect_mask((cx - bw * 1.3, cy + bh * 0.05, cx + bw * 1.3, cy + bh * 0.3), 8), k.bm)
    _chunk(img, rim, shade_col(k.col, 0.7), k.dark, 3, amount=0.3)
    for i in range(7):
        x = cx - bw * 1.0 + i * bw * 0.333
        lm = ellipse_mask((x - 11, cy + bh * 0.08, x + 11, cy + bh * 0.28))
        c = hsv(0.13, 0.7, 1.0) if i % 2 else hsv(0.5, 0.6, 1.0)
        glow(img, lm, c, 8)
        fill(img, lm, c)
    # glass dome sheen
    dome = ellipse_mask((cx - bw * 0.62, cy - bh * 0.85, cx + bw * 0.62, cy + bh * 0.25))
    fill(img, ImageChops.subtract(dome, ImageChops.offset(dome, 10, 12)), (255, 255, 255, 120))
    fill(img, dome, hsv(0.5, 0.3, 1.0, 40))


def vr_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    vm = rrect_mask((cx - bw * 0.78, cy - bh * 0.42, cx + bw * 0.78, cy + bh * 0.02), 22)
    _chunk(img, vm, (36, 36, 46, 255), INK, 4, spec=0.5)
    lens = rrect_mask((cx - bw * 0.68, cy - bh * 0.34, cx + bw * 0.68, cy - bh * 0.06), 14)
    glow(img, lens, hsv(0.5, 0.9, 1.0), 12)
    fill(img, lens, hsv(0.5, 0.8, 1.0, 150))
    fill(img, ImageChops.subtract(lens, ImageChops.offset(lens, 6, 6)), (255, 255, 255, 140))
    strap = ImageChops.subtract(rrect_mask((cx - bw * 1.02, cy - bh * 0.36, cx + bw * 1.02, cy - bh * 0.08), 8), dilate(vm, 2))
    fill(img, ImageChops.multiply(strap, dilate(k.bm, 6)), (36, 36, 46, 255))
    # sweat band / headband
    hb = ImageChops.multiply(rrect_mask((cx - bw, cy - bh * 0.85, cx + bw, cy - bh * 0.62), 6), k.bm)
    _chunk(img, hb, RED, RED_D, 3, amount=0.3)


def granny_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # bun + grey hair
    _chunk(img, ImageChops.multiply(ellipse_mask((cx - bw * 0.8, cy - bh * 1.1, cx + bw * 0.8, cy - bh * 0.55)), dilate(k.bm, 3)), (200, 200, 210, 255), INK, 3, amount=0.3)
    _chunk(img, ellipse_mask((cx - 34, cy - bh * 1.22, cx + 34, cy - bh * 0.78)), (210, 210, 220, 255), INK, 4, amount=0.4)
    # spectacles
    for s in (-1, 1):
        ex = cx + s * bw * 0.38
        ring = ImageChops.subtract(ellipse_mask((ex - bw * 0.26, cy - bh * 0.4, ex + bw * 0.26, cy + bh * 0.1)),
                                   ellipse_mask((ex - bw * 0.21, cy - bh * 0.35, ex + bw * 0.21, cy + bh * 0.05)))
        _chunk(img, ring, GOLD, GOLD_D, 2, amount=0.3)
        fill(img, ellipse_mask((ex - bw * 0.21, cy - bh * 0.35, ex + bw * 0.21, cy + bh * 0.05)), (255, 255, 255, 50))
    fill(img, rrect_mask((cx - bw * 0.14, cy - bh * 0.2, cx + bw * 0.14, cy - bh * 0.14), 2), GOLD)
    # shawl + cane
    _chunk(img, ImageChops.multiply(poly_mask([(cx - bw, cy + bh * 0.5), (cx + bw, cy + bh * 0.5), (cx + bw, cy + bh), (cx - bw, cy + bh)]), dilate(k.bm, 3)), hsv(0.75, 0.35, 0.6), INK, 3)
    texture(img, k.bm, "cloth", k.col, k.dark, k.rng, (cx - bw, cy + bh * 0.5, cx + bw, cy + bh))
    cane = rrect_mask((cx + bw * 0.95, cy - bh * 0.1, cx + bw * 0.95 + 12, cy + bh * 1.25), 5)
    _chunk(img, cane, (120, 80, 40, 255), INK, 3)
    _chunk(img, ellipse_mask((cx + bw * 0.95 - 14, cy - bh * 0.3, cx + bw * 0.95 + 26, cy - bh * 0.05)), (140, 95, 45, 255), INK, 3)


def albot_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    hatch = rrect_mask((cx - bw * 0.5, cy + bh * 0.25, cx + bw * 0.5, cy + bh * 0.8), 10)
    _chunk(img, hatch, (30, 30, 40, 255), INK, 4, amount=0.3)
    port = ellipse_mask((cx - bw * 0.36, cy + bh * 0.32, cx + bw * 0.36, cy + bh * 0.73))
    glow(img, port, RED, 18, 1.3)
    shaded(img, port, RED, amount=0.5, spec=0.6)
    fill(img, ellipse_mask((cx - bw * 0.14, cy + bh * 0.46, cx + bw * 0.14, cy + bh * 0.6)), (255, 240, 240, 255))
    for x in (cx - bw * 0.85, cx + bw * 0.85):  # bolts
        for y in (cy - bh * 0.8, cy + bh * 0.85):
            _chunk(img, ellipse_mask((x - 9, y - 9, x + 9, y + 9)), (180, 180, 195, 255), INK, 2, spec=0.5)
    ant = rrect_mask((cx - 5, cy - bh * 1.35, cx + 5, cy - bh * 0.9), 3)
    _chunk(img, ant, (170, 170, 185, 255), INK, 3)
    bulb = ellipse_mask((cx - 13, cy - bh * 1.5, cx + 13, cy - bh * 1.28))
    glow(img, bulb, RED, 12)
    fill(img, bulb, RED)


def jumper_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for s in (-1, 1):  # coil-spring legs
        x = cx + s * bw * 0.45
        pts = [(x, cy + bh * 0.6)]
        for i in range(6):
            pts.append((x + s * (18 if i % 2 else -18), cy + bh * 0.6 + (i + 1) * 20))
        pts.append((x + s * 10, cy + bh * 0.6 + 150))
        limb(img, pts, 11, 11, shade_col(k.col, 0.7), k.dark, segs=40)
        foot = ellipse_mask((x + s * 10 - 42, cy + bh * 0.6 + 138, x + s * 10 + 42, cy + bh * 0.6 + 172))
        _chunk(img, foot, k.col, k.dark, 4)


def giant_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for s in (-1, 1):  # huge fists
        limb(img, [(cx + s * bw * 0.6, cy + bh * 0.2), (cx + s * bw * 0.95, cy + bh * 0.3), (cx + s * bw * 1.05, cy + bh * 0.6)], 30, 30, k.col, k.dark)
        fm = ellipse_mask((cx + s * bw * 1.1 - 68, cy + bh * 0.35, cx + s * bw * 1.1 + 68, cy + bh * 1.05))
        _chunk(img, fm, k.col, k.dark, 6, amount=0.45)
        t = mask_new()
        d = ImageDraw.Draw(t)
        for i in range(3):
            d.line([(cx + s * bw * 1.1 - 34 + i * 34, cy + bh * 0.48), (cx + s * bw * 1.1 - 34 + i * 34, cy + bh * 0.72)], fill=255, width=6)
        fill(img, ImageChops.multiply(t, fm), shade_col(k.dark, 1.0, 180))
    # brow ridge
    _chunk(img, ImageChops.multiply(rrect_mask((cx - bw * 0.8, cy - bh * 0.6, cx + bw * 0.8, cy - bh * 0.38), 10), k.bm), shade_col(k.col, 0.65), k.dark, 4)


def gardener_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    leaf = hsv(0.3, 0.85, 0.7)
    for i, a in enumerate((-70, -40, -12, 12, 40, 70)):  # leaf crown
        r = math.radians(a - 90)
        L = bh * (0.75 if i in (2, 3) else 0.6)
        tip = (cx + math.cos(r) * (bh * 0.6 + L), cy - bh * 0.35 + math.sin(r) * (bh * 0.6 + L))
        base = (cx + math.cos(r) * bh * 0.55, cy - bh * 0.35 + math.sin(r) * bh * 0.55)
        px, py = -math.sin(r) * 26, math.cos(r) * 26
        mid = ((tip[0] + base[0]) / 2, (tip[1] + base[1]) / 2)
        m = poly_mask([base, (mid[0] + px, mid[1] + py), tip, (mid[0] - px, mid[1] - py)])
        m = soften(m, 4)
        _chunk(img, m, leaf, k.dark, 4, amount=0.5)
        fill(img, ImageChops.multiply(poly_mask([base, tip, (tip[0] + 2, tip[1] + 2)]), dilate(m, 0)), (0, 0, 0, 0))
    fl = star_mask(cx + bw * 0.55, cy - bh * 0.95, 34, 6, 0.55)
    _chunk(img, fl, hsv(0.95, 0.7, 1.0), k.dark, 3, amount=0.3)
    fill(img, ellipse_mask((cx + bw * 0.55 - 12, cy - bh * 0.95 - 12, cx + bw * 0.55 + 12, cy - bh * 0.95 + 12)), GOLD)


def army_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    helm = ImageChops.lighter(ellipse_mask((cx - bw * 1.02, cy - bh * 1.15, cx + bw * 1.02, cy - bh * 0.1)),
                              rrect_mask((cx - bw * 1.12, cy - bh * 0.55, cx + bw * 1.12, cy - bh * 0.4), 6))
    _chunk(img, helm, hsv(0.2, 0.45, 0.42), k.dark, 5, amount=0.4, spec=0.3)
    fill(img, star_mask(cx, cy - bh * 0.78, 24), RED)
    # bandolier
    strap = ImageChops.multiply(poly_mask([(cx - bw, cy + bh * 0.1), (cx - bw + 26, cy + bh * 0.1), (cx + bw, cy + bh * 0.95), (cx + bw - 26, cy + bh * 0.95)]), k.bm)
    _chunk(img, strap, (70, 50, 30, 255), INK, 3, amount=0.3)
    for i in range(4):
        t = 0.25 + i * 0.17
        x, y = cx - bw + 13 + t * (2 * bw - 26), cy + bh * 0.1 + t * bh * 0.85
        _chunk(img, rrect_mask((x - 5, y - 11, x + 5, y + 11), 2), GOLD, GOLD_D, 2)


def morpher_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for i, (sh, dx, dy, h) in enumerate((("square", -55, 30, 0.55), ("round", 60, -20, 0.1), ("tri", 10, -70, 0.3))):
        m = body_mask(sh, cx + dx, cy + dy, bw * 0.75, bh * 0.75)
        m = ImageChops.subtract(soften(m, 5), erode(k.bm, 10))
        c = hsv(h, 0.8, 0.9, 170)
        outline(img, m, hsv(h, 0.9, 0.2, 200), 4)
        shaded(img, m, c, amount=0.4)


def morpher_front(k):
    texture(k.img, k.bm, "slime", k.col, k.dark, k.rng, k.box)
    fill(k.img, ImageChops.multiply(poly_mask([(k.cx + k.bw, k.cy), (k.cx, k.cy + k.bh), (k.cx + k.bw * 0.2, k.cy - k.bh * 0.2)]), k.bm), hsv(0.1, 0.8, 1.0, 90))


def fusion_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # two heads growing from one body, glowing seam between
    for s, h in ((-1, k.hue), (1, k.hue + 0.12)):
        hm = ellipse_mask((cx + s * bw * 0.45 - bw * 0.42, cy - bh * 1.05, cx + s * bw * 0.45 + bw * 0.42, cy - bh * 0.05))
        c = hsv(h, k.sat, 0.85)
        _chunk(img, hm, c, k.dark, 6, amount=0.45, spec=0.35)
        eye(img, cx + s * bw * 0.45, cy - bh * 0.55, bw * 0.2, hsv(h + 0.5, 0.85, 0.9), look=(-0.2 * s, 0.1), lid="angry" if s > 0 else None, lid_col=k.dark)
        mouth(img, cx + s * bw * 0.45, cy - bh * 0.22, bw * 0.2, bh * 0.07, "grin" if s > 0 else "small", teeth=3)
    fill(img, ImageChops.multiply(rrect_mask((cx, 0, S, S), 0), k.bm), hsv(k.hue + 0.12, 0.8, 0.9, 150))
    seam = rrect_mask((cx - 6, cy - bh * 0.55, cx + 6, cy + bh * 0.85), 5)
    glow(img, seam, hsv(0.13, 0.6, 1.0), 14, 1.3)
    fill(img, seam, hsv(0.13, 0.3, 1.0))


def crippler_back(k):
    m = spikes_mask(k.cx, k.cy, k.bw * 0.9, k.bh * 0.85, 12, k.bw * 0.3, 0.4, -120, 240, k.rng)
    _chunk(k.img, m, shade_col(k.col, 0.7), k.dark, 4, amount=0.5)


def crippler_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # broken blade emblem: a snapped sword
    bl = poly_mask([(cx - 12, cy + bh * 0.12), (cx + 12, cy + bh * 0.12), (cx + 14, cy + bh * 0.5), (cx - 4, cy + bh * 0.42), (cx - 14, cy + bh * 0.55)])
    _chunk(img, bl, (200, 205, 215, 255), INK, 3, spec=0.5)
    _chunk(img, rrect_mask((cx - 26, cy + bh * 0.05, cx + 26, cy + bh * 0.13), 3), GOLD, GOLD_D, 2)
    for i in range(3):
        fill(img, poly_mask([(cx - 20 + i * 18, cy + bh * 0.6), (cx - 14 + i * 18, cy + bh * 0.72), (cx - 8 + i * 18, cy + bh * 0.58)]), (200, 205, 215, 255))


def splash_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for i in range(10):  # flying droplets
        a = math.radians(-160 + i * 32)
        r = bw * k.rng.uniform(1.15, 1.45)
        x, y = cx + math.cos(a) * r, cy + math.sin(a) * r * 0.9
        d = k.rng.uniform(8, 18)
        m = ImageChops.lighter(ellipse_mask((x - d, y - d, x + d, y + d)), poly_mask([(x - d, y), (x + d, y), (x, y - d * 2.2)]))
        _chunk(img, m, hsv(0.52, 0.5, 1.0), k.dark, 3, spec=0.6)
    # splash ring under body
    ring = ImageChops.subtract(ellipse_mask((cx - bw * 1.4, cy + bh * 0.45, cx + bw * 1.4, cy + bh * 1.25)),
                               ellipse_mask((cx - bw * 1.2, cy + bh * 0.58, cx + bw * 1.2, cy + bh * 1.12)))
    _chunk(img, ring, hsv(0.52, 0.5, 0.95), k.dark, 3, amount=0.3)


def splash_front(k):
    tip = poly_mask([(k.cx - k.bw * 0.5, k.cy - k.bh * 0.75), (k.cx + k.bw * 0.5, k.cy - k.bh * 0.75), (k.cx, k.cy - k.bh * 1.45)])
    tip = ImageChops.subtract(soften(tip, 6), erode(k.bm, 4))
    _chunk(k.img, tip, k.col, k.dark, 6, amount=0.4)


def virus_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    m = spikes_mask(cx, cy, bw * 0.92, bh * 0.92, 18, bw * 0.32, 0.28, -90, 360, k.rng)
    _chunk(img, m, shade_col(k.col, 0.8), k.dark, 4, amount=0.5)
    for i in range(18):  # knobs on spike tips
        a = math.radians(-90 + i * 20)
        x, y = cx + math.cos(a) * bw * 1.24, cy + math.sin(a) * bh * 1.24
        glow(img, ellipse_mask((x - 9, y - 9, x + 9, y + 9)), hsv(0.3, 0.9, 1.0), 6)
        _chunk(img, ellipse_mask((x - 9, y - 9, x + 9, y + 9)), hsv(0.3, 0.6, 1.0), k.dark, 2, spec=0.5)


def guardian_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    helm = ImageChops.lighter(ellipse_mask((cx - bw * 1.0, cy - bh * 1.2, cx + bw * 1.0, cy - bh * 0.1)),
                              rrect_mask((cx - bw * 0.16, cy - bh * 1.45, cx + bw * 0.16, cy - bh * 0.9), 6))
    _chunk(img, helm, shade_col(k.col, 0.7), k.dark, 6, amount=0.45, spec=0.5)
    fill(img, ImageChops.subtract(helm, erode(helm, 10)), (255, 255, 255, 35))


def guardian_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    wall = rrect_mask((cx - bw * 1.35, cy + bh * 0.15, cx + bw * 1.35, cy + bh * 1.25), 14)
    _chunk(img, wall, shade_col(k.col, 0.75), k.dark, 6, amount=0.35, spec=0.4)
    t = mask_new()
    d = ImageDraw.Draw(t)
    d.line([(cx - bw * 1.35, cy + bh * 0.62), (cx + bw * 1.35, cy + bh * 0.62)], fill=255, width=5)
    for i in range(6):
        d.line([(cx - bw * 1.1 + i * bw * 0.45, cy + bh * 0.15), (cx - bw * 1.1 + i * bw * 0.45, cy + bh * 1.25)], fill=255, width=4)
    fill(img, ImageChops.multiply(t, wall), shade_col(k.dark, 1.0, 190))
    fill(img, ImageChops.subtract(wall, erode(wall, 8)), (255, 255, 255, 40))
    for x in (cx - bw * 1.15, cx + bw * 1.15):
        for y in (cy + bh * 0.35, cy + bh * 1.05):
            _chunk(img, ellipse_mask((x - 10, y - 10, x + 10, y + 10)), RED, RED_D, 2, spec=0.5)
    fill(img, star_mask(cx, cy + bh * 0.7, bw * 0.3, 4, 0.4), RED)
    for s in (-1, 1):
        _chunk(img, ellipse_mask((cx + s * bw * 0.95 - 34, cy + bh * 0.0, cx + s * bw * 0.95 + 34, cy + bh * 0.4)), k.col, k.dark, 5, amount=0.45)


def hood_back(k, col):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    hood = poly_mask([(cx, cy - bh * 1.5), (cx + bw * 1.25, cy + bh * 0.1), (cx + bw * 1.15, cy + bh * 1.25), (cx - bw * 1.15, cy + bh * 1.25), (cx - bw * 1.25, cy + bh * 0.1)])
    hood = soften(hood, 10)
    _chunk(img, hood, col, k.dark, 6, amount=0.5, spec=0.1)
    texture(img, hood, "cloth", col, k.dark, k.rng, (cx - bw * 1.3, cy - bh * 1.5, cx + bw * 1.3, cy + bh * 1.3))
    inner = ImageChops.multiply(hood, ellipse_mask((cx - bw * 0.95, cy - bh * 0.95, cx + bw * 0.95, cy + bh * 0.95)))
    fill(img, inner, (14, 8, 20, 255))


def dark_arts_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for s in (-1, 1):
        ox, oy = cx + s * bw * 1.0, cy + bh * 0.75
        orb = ellipse_mask((ox - 30, oy - 30, ox + 30, oy + 30))
        glow(img, orb, hsv(0.78, 0.9, 1.0), 22, 1.4)
        _chunk(img, orb, hsv(0.78, 0.6, 1.0), k.dark, 3, spec=0.6)
        fill(img, star_mask(ox, oy, 12, 4, 0.3), WHITE)
    # runes on chest
    for i, ch in enumerate("+x^"):
        fill(img, text_mask(ch, 34, cx - 40 + i * 40, cy + bh * 0.1), hsv(0.78, 0.5, 1.0, 220))


def rare_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(6):  # facets
        a = math.radians(i * 60 + 15)
        d.line([(cx, cy), (cx + math.cos(a) * bw * 1.5, cy + math.sin(a) * bh * 1.5)], fill=255, width=4)
    fill(img, ImageChops.multiply(t, erode(k.bm, 4)), (255, 255, 255, 80))
    fill(img, ImageChops.multiply(poly_mask([(cx - bw, cy - bh), (cx + bw * 0.2, cy - bh), (cx - bw, cy + bh * 0.3)]), erode(k.bm, 4)), (255, 255, 255, 70))
    for s in (-1, 1):  # gem shards orbiting
        for j in range(2):
            gx, gy = cx + s * bw * (1.2 + 0.12 * j), cy - bh * (0.55 - 0.8 * j)
            g = poly_mask([(gx, gy - 36), (gx + 20, gy - 8), (gx + 12, gy + 30), (gx - 12, gy + 30), (gx - 20, gy - 8)])
            glow(img, g, hsv(0.6, 0.8, 1.0), 10)
            _chunk(img, g, hsv(0.6, 0.5, 1.0), k.dark, 3, spec=0.6)


def bunker_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    # visor slit over eyes
    slit = rrect_mask((cx - bw * 0.8, cy - bh * 0.32, cx + bw * 0.8, cy + bh * 0.02), 6)
    _chunk(img, slit, (28, 24, 22, 255), INK, 4, amount=0.2)
    for s in (-1, 1):
        e = ellipse_mask((cx + s * bw * 0.38 - 18, cy - bh * 0.22, cx + s * bw * 0.38 + 18, cy - bh * 0.08))
        glow(img, e, hsv(0.13, 0.8, 1.0), 10)
        fill(img, e, hsv(0.13, 0.6, 1.0))
    # steel door + sandbags
    door = rrect_mask((cx - bw * 0.3, cy + bh * 0.15, cx + bw * 0.3, cy + bh * 0.8), 8)
    _chunk(img, door, (110, 110, 120, 255), INK, 4, spec=0.4)
    fill(img, ImageChops.subtract(door, erode(door, 6)), (60, 60, 70, 255))
    for i in range(6):
        x = cx - bw * 1.05 + i * bw * 0.42
        _chunk(img, ellipse_mask((x - 30, cy + bh * 0.82, x + 30, cy + bh * 1.15)), hsv(0.12, 0.35, 0.6), k.dark, 3, amount=0.35)
    for i in range(5):
        x = cx - bw * 0.85 + i * bw * 0.42
        _chunk(img, ellipse_mask((x - 30, cy + bh * 1.05, x + 30, cy + bh * 1.38)), hsv(0.12, 0.35, 0.55), k.dark, 3, amount=0.35)


def interdim_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    portal = ellipse_mask((cx - bw * 1.55, cy - bh * 1.45, cx + bw * 1.55, cy + bh * 1.45))
    glow(img, portal, hsv(k.hue, 0.9, 1.0), 26, 1.2)
    fill(img, portal, (12, 6, 30, 255))
    for i in range(3):  # swirl arcs
        a = mask_new()
        r = bw * (1.45 - 0.3 * i)
        ImageDraw.Draw(a).arc((cx - r, cy - r * 0.95, cx + r, cy + r * 0.95), 200 + i * 70, 20 + i * 70, fill=255, width=6)
        c = hsv(k.hue + 0.06 * i, 0.7, 1.0)
        glow(img, a, c, 10)
        fill(img, a, c[:3] + (220,))
    for _ in range(16):
        x, y = cx + k.rng.uniform(-bw * 1.4, bw * 1.4), cy + k.rng.uniform(-bh * 1.3, bh * 1.3)
        fill(img, ImageChops.multiply(star_mask(x, y, k.rng.uniform(4, 9), 4, 0.35), portal), (255, 255, 255, 220))
    for dx, h in ((-40, 0.5), (40, 0.9)):  # chromatic ghost copies
        m = soften(body_mask("diamond", cx + dx, cy, bw, bh), 6)
        fill(img, m, hsv(h, 0.9, 1.0, 120))


def scarce_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for s in (-1, 1):  # crystal shoulder spikes
        for j in range(3):
            x, y = cx + s * bw * (0.85 + j * 0.22), cy - bh * (0.15 - j * 0.12)
            m = poly_mask([(x - 16, y + 34), (x + 16, y + 34), (x + s * 10, y - 70 + j * 14)])
            glow(img, m, hsv(0.8, 0.9, 1.0), 10)
            _chunk(img, m, hsv(0.8, 0.5, 1.0), k.dark, 3, spec=0.6)


def hevalgod_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for i in range(8):  # halo of fire rays
        a = math.radians(-90 + i * 45)
        m = poly_mask([(cx + math.cos(a + 0.18) * bw * 1.1, cy + math.sin(a + 0.18) * bh * 1.1),
                       (cx + math.cos(a - 0.18) * bw * 1.1, cy + math.sin(a - 0.18) * bh * 1.1),
                       (cx + math.cos(a) * bw * 1.75, cy + math.sin(a) * bh * 1.75)])
        glow(img, m, RED, 14)
        _chunk(img, m, hsv(0.05, 0.9, 1.0), RED_D, 3, amount=0.4)


def hevalgod_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    tentacles(img, cx, cy + bh * 0.62, 5, bh * 0.55, bw * 0.5, shade_col(k.col, 0.85), k.dark, k.rng, base_w=12)
    glow(img, ellipse_mask((cx - 24, cy + bh * 0.15, cx + 24, cy + bh * 0.45)), hsv(0.12, 0.8, 1.0), 16, 1.4)
    fill(img, star_mask(cx, cy + bh * 0.3, 22, 5, 0.5), hsv(0.13, 0.5, 1.0))


def gos_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    ring = ImageChops.subtract(ellipse_mask((cx - bw * 1.7, cy - bh * 0.3, cx + bw * 1.7, cy + bh * 0.55)),
                               ellipse_mask((cx - bw * 1.35, cy - bh * 0.15, cx + bw * 1.35, cy + bh * 0.4)))
    glow(img, ring, GOLD, 14)
    _chunk(img, ring, hsv(0.12, 0.5, 0.95), GOLD_D, 4, amount=0.3)
    for _ in range(14):
        x, y = cx + k.rng.uniform(-bw * 1.6, bw * 1.6), cy + k.rng.uniform(-bh * 1.4, bh * 1.4)
        fill(img, star_mask(x, y, k.rng.uniform(4, 10), 4, 0.35), (255, 250, 220, 230))


def gos_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    front = ImageChops.subtract(ellipse_mask((cx - bw * 1.7, cy - bh * 0.3, cx + bw * 1.7, cy + bh * 0.55)),
                                ellipse_mask((cx - bw * 1.35, cy - bh * 0.15, cx + bw * 1.35, cy + bh * 0.4)))
    front = ImageChops.multiply(front, rrect_mask((0, cy + bh * 0.12, S, S), 0))
    _chunk(img, front, hsv(0.12, 0.5, 0.95), GOLD_D, 4, amount=0.3)
    for i in range(3):  # small spawned orbs
        x, y = cx - bw * 0.5 + i * bw * 0.5, cy + bh * 0.68
        o = ellipse_mask((x - 16, y - 16, x + 16, y + 16))
        glow(img, o, hsv(0.13, 0.8, 1.0), 12)
        _chunk(img, o, hsv(0.13 + 0.3 * i, 0.7, 1.0), k.dark, 3, spec=0.6)


def swarm_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for s in (-1, 1):  # wings
        w = ellipse_mask((cx + s * bw * 0.75 - bw * 0.55, cy - bh * 0.9, cx + s * bw * 0.75 + bw * 0.55, cy + bh * 0.1))
        fill(img, dilate(w, 3), hsv(0.5, 0.3, 0.9, 120))
        fill(img, w, hsv(0.5, 0.2, 1.0, 110))
        t = mask_new()
        d = ImageDraw.Draw(t)
        for i in range(3):
            d.line([(cx + s * bw * 0.3, cy - bh * 0.3), (cx + s * bw * (0.9 + 0.2 * i), cy - bh * (0.8 - 0.3 * i))], fill=255, width=3)
        fill(img, ImageChops.multiply(t, w), hsv(0.5, 0.3, 0.6, 180))
        for i in range(3):  # 6 thin legs
            limb(img, [(cx + s * bw * 0.4, cy + bh * (0.1 + 0.25 * i)), (cx + s * bw * (0.9 + 0.1 * i), cy + bh * (0.05 + 0.3 * i)), (cx + s * bw * (1.1 + 0.1 * i), cy + bh * (0.55 + 0.25 * i))], 5, 4, shade_col(k.col, 0.8), k.dark)
    antennae(img, cx, cy - bh * 0.6, k.col, k.dark, 2, 70, bulb=True, bulb_col=hsv(0.13, 0.8, 1.0), spread=30)


def swarm_front(k):
    for s in (-1, 1):  # mandibles
        m = poly_mask([(k.cx + s * k.bw * 0.15, k.cy + k.bh * 0.55), (k.cx + s * k.bw * 0.45, k.cy + k.bh * 0.7), (k.cx + s * k.bw * 0.2, k.cy + k.bh * 1.0)])
        _chunk(k.img, m, shade_col(k.col, 0.7), k.dark, 3)


def shieldbearer_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    helm = ImageChops.multiply(rrect_mask((cx - bw * 1.05, cy - bh * 1.15, cx + bw * 1.05, cy - bh * 0.45), 26), dilate(k.bm, 4))
    _chunk(img, helm, (150, 150, 165, 255), INK, 4, spec=0.5)
    _chunk(img, rrect_mask((cx - 8, cy - bh * 1.45, cx + 8, cy - bh * 0.9), 4), RED, RED_D, 3)
    shield(img, cx - bw * 0.85, cy + bh * 0.45, bw * 0.62, bh * 0.75, hsv(0.13, 0.7, 0.9), GOLD_D, emblem="star")
    limb(img, [(cx + bw * 0.6, cy + bh * 0.1), (cx + bw * 1.15, cy + bh * 0.05), (cx + bw * 1.25, cy - bh * 0.5)], 15, 12, k.col, k.dark)
    _chunk(img, rrect_mask((cx + bw * 1.18, cy - bh * 1.15, cx + bw * 1.32, cy - bh * 0.4), 5), (120, 90, 50, 255), INK, 3)
    _chunk(img, poly_mask([(cx + bw * 1.15, cy - bh * 1.15), (cx + bw * 1.35, cy - bh * 1.15), (cx + bw * 1.25, cy - bh * 1.45)]), (200, 205, 215, 255), INK, 3)


def phaser_back(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    for dx, h in ((-34, 0.92), (34, 0.5)):
        m = soften(body_mask("diamond", cx + dx, cy, bw, bh), 7)
        fill(img, dilate(m, 4), hsv(h, 0.9, 1.0, 130))
        fill(img, ImageChops.subtract(dilate(m, 4), m), hsv(h, 0.9, 1.0, 240))
    energy_aura(img, k.bm, hsv(0.5, 0.8, 1.0), 30)


def phaser_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    t = mask_new()
    d = ImageDraw.Draw(t)
    for i in range(7):  # scanline shimmer
        y = cy - bh + i * bh * 0.3
        d.line([(cx - bw, y), (cx + bw, y)], fill=255, width=3)
    fill(img, ImageChops.multiply(t, k.bm), (255, 255, 255, 70))
    core = soften(body_mask("diamond", cx, cy + bh * 0.3, bw * 0.22, bh * 0.22), 3)
    glow(img, core, hsv(0.5, 0.7, 1.0), 16, 1.4)
    fill(img, core, (240, 255, 255, 255))


def medic_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    cap = ImageChops.multiply(rrect_mask((cx - bw * 0.75, cy - bh * 1.15, cx + bw * 0.75, cy - bh * 0.6), 14), dilate(k.bm, 6))
    _chunk(img, cap, WHITE, INK, 4, amount=0.25)
    fill(img, ImageChops.lighter(rrect_mask((cx - 8, cy - bh * 1.08, cx + 8, cy - bh * 0.66), 2), rrect_mask((cx - 26, cy - bh * 0.92, cx + 26, cy - bh * 0.82), 2)), RED)
    badge = ellipse_mask((cx - bw * 0.36, cy + bh * 0.12, cx + bw * 0.36, cy + bh * 0.85))
    _chunk(img, badge, WHITE, INK, 4, amount=0.25)
    fill(img, ImageChops.lighter(rrect_mask((cx - 12, cy + bh * 0.2, cx + 12, cy + bh * 0.77), 3), rrect_mask((cx - bw * 0.28, cy + bh * 0.4, cx + bw * 0.28, cy + bh * 0.57), 3)), RED)
    # syringe in right hand
    x, y = cx + bw * 1.15, cy + bh * 0.2
    _chunk(img, rrect_mask((x - 10, y - 60, x + 10, y + 30), 3), (220, 235, 245, 255), INK, 3, spec=0.5)
    fill(img, rrect_mask((x - 7, y - 20, x + 7, y + 27), 2), hsv(0.35, 0.8, 1.0))
    fill(img, rrect_mask((x - 2, y - 95, x + 2, y - 60), 1), (200, 200, 210, 255))
    fill(img, rrect_mask((x - 16, y + 30, x + 16, y + 38), 2), (200, 200, 210, 255))


def thief_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    band = ImageChops.multiply(rrect_mask((cx - bw * 0.95, cy - bh * 0.38, cx + bw * 0.95, cy - bh * 0.02), 10), dilate(k.bm, 4))
    _chunk(img, band, (30, 26, 36, 255), INK, 3, amount=0.3)
    for s in (-1, 1):  # eye holes through the mask
        h = ellipse_mask((cx + s * bw * 0.38 - 26, cy - bh * 0.34, cx + s * bw * 0.38 + 26, cy - bh * 0.06))
        fill(img, h, (250, 250, 240, 255))
        fill(img, ellipse_mask((cx + s * bw * 0.38 - 10 + s * 5, cy - bh * 0.26, cx + s * bw * 0.38 + 10 + s * 5, cy - bh * 0.13)), INK)
    _chunk(img, ImageChops.multiply(rrect_mask((cx - bw * 1.0, cy - bh * 1.12, cx + bw * 1.0, cy - bh * 0.62), 14), dilate(k.bm, 4)), (36, 32, 42, 255), INK, 4)
    # loot sack with $
    sx, sy = cx + bw * 1.1, cy + bh * 0.6
    sack = ImageChops.lighter(ellipse_mask((sx - 48, sy - 40, sx + 48, sy + 50)), poly_mask([(sx - 20, sy - 35), (sx + 20, sy - 35), (sx + 8, sy - 70), (sx - 8, sy - 70)]))
    _chunk(img, sack, (150, 110, 60, 255), INK, 4, amount=0.4)
    fill(img, rrect_mask((sx - 20, sy - 48, sx + 20, sy - 36), 4), (90, 60, 30, 255))
    fill(img, text_mask("$", 46, sx, sy + 6), GOLD)
    for i in range(3):
        _chunk(img, ellipse_mask((sx - 60 + i * 22, sy + 44, sx - 42 + i * 22, sy + 60)), GOLD, GOLD_D, 2, spec=0.5)


def splitter_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    fill(img, ImageChops.multiply(rrect_mask((cx, cy - bh * 2, cx + bw * 2, cy + bh * 2), 0), k.bm), (0, 0, 0, 40))
    pts = [(cx, cy - bh * 1.1)]
    y = cy - bh
    i = 0
    while y < cy + bh * 1.1:
        pts.append((cx + (12 if i % 2 else -12), y))
        y += 26
        i += 1
    seam = mask_new()
    ImageDraw.Draw(seam).line(pts, fill=255, width=14)
    seam = ImageChops.multiply(seam, k.bm)
    glow(img, seam, hsv(0.13, 0.8, 1.0), 10)
    fill(img, seam, k.dark)
    fill(img, erode(seam, 4), hsv(0.13, 0.5, 1.0))


def anchor_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    ax, ay = cx, cy + bh * 0.62
    m = mask_new()
    d = ImageDraw.Draw(m)
    d.rectangle((ax - 7, ay - 60, ax + 7, ay + 40), fill=255)
    d.rectangle((ax - 40, ay - 42, ax + 40, ay - 30), fill=255)
    d.arc((ax - 48, ay - 30, ax + 48, ay + 50), 20, 160, fill=255, width=14)
    d.polygon([(ax - 56, ay + 8), (ax - 36, ay + 22), (ax - 44, ay + 34)], fill=255)
    d.polygon([(ax + 56, ay + 8), (ax + 36, ay + 22), (ax + 44, ay + 34)], fill=255)
    d.ellipse((ax - 16, ay - 84, ax + 16, ay - 52), fill=255)
    d.ellipse((ax - 8, ay - 76, ax + 8, ay - 60), fill=0)
    _chunk(img, m, (185, 190, 205, 255), INK, 4, spec=0.5)
    # chains dangling off the sides
    for s in (-1, 1):
        for j in range(5):
            x, y = cx + s * bw * 1.08 + s * j * 5, cy + bh * 0.35 + j * 28
            ring = ImageChops.subtract(ellipse_mask((x - 12, y - 16, x + 12, y + 16)), ellipse_mask((x - 5, y - 9, x + 5, y + 9)))
            _chunk(img, ring, (150, 155, 170, 255), INK, 3, spec=0.4)


def necro_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    sx = cx + bw * 1.15
    _chunk(img, rrect_mask((sx - 9, cy - bh * 1.1, sx + 9, cy + bh * 1.3), 4), (90, 60, 40, 255), INK, 4)
    glow(img, ellipse_mask((sx - 40, cy - bh * 1.5, sx + 40, cy - bh * 0.8)), hsv(0.35, 0.9, 1.0), 20, 1.3)
    skull(img, sx, cy - bh * 1.18, 34)
    for s in (-1, 1):
        fill(img, ellipse_mask((sx + s * 15 - 8, cy - bh * 1.28, sx + s * 15 + 8, cy - bh * 1.1)), hsv(0.35, 0.8, 1.0))
    for s in (-1, 1):  # bone spikes on both shoulders
        for i in range(3):
            x = cx + s * bw * (0.7 + i * 0.22)
            m = poly_mask([(x - 10, cy - bh * 0.25), (x + 10, cy - bh * 0.25), (x + s * 6, cy - bh * (0.85 - i * 0.12))])
            _chunk(img, m, (225, 220, 205, 255), INK, 3)


def titan_front(k):
    cx, cy, bw, bh, img = k.cx, k.cy, k.bw, k.bh, k.img
    core = ellipse_mask((cx - bw * 0.3, cy + bh * 0.2, cx + bw * 0.3, cy + bh * 0.72))
    socket = dilate(core, 12)
    _chunk(img, socket, (20, 16, 34, 255), INK, 4, amount=0.3)
    glow(img, core, hsv(0.72, 0.8, 1.0), 26, 1.6)
    shaded(img, core, hsv(0.72, 0.6, 1.0), amount=0.5, spec=0.7)
    fill(img, ellipse_mask((cx - bw * 0.12, cy + bh * 0.36, cx + bw * 0.12, cy + bh * 0.56)), (255, 255, 255, 255))
    for s in (-1, 1):  # pauldrons
        p = ellipse_mask((cx + s * bw * 0.95 - 60, cy - bh * 0.5, cx + s * bw * 0.95 + 60, cy + bh * 0.15))
        _chunk(img, p, shade_col(k.col, 0.7), k.dark, 6, amount=0.45, spec=0.4)
        fill(img, ImageChops.subtract(p, erode(p, 8)), (255, 255, 255, 40))
        _chunk(img, poly_mask([(cx + s * bw * 1.1, cy - bh * 0.4), (cx + s * bw * 1.4, cy - bh * 0.35), (cx + s * bw * 1.2, cy - bh * 0.95)]), RED, RED_D, 3)
    texture(img, k.bm, "cracks", k.col, k.dark, k.rng, k.box)


RECIPES = {
    "Joe": dict(limbs=[("legs", 2), ("arms",), ("antennae", 2)], texture="spots", mouth_kind="grin", teeth=4, eye=dict(lid=None)),
    "Gen57": dict(limbs=[("legs", 2), ("arms",), ("antennae", 1)], texture="plates", front=gen57_front, mouth_kind="small",
                  eye=dict(glow=hsv(0.55, 0.8, 1.0), iris=hsv(0.55, 0.9, 0.5))),
    "President": dict(limbs=[("arms",)], front=president_front, mouth_kind="small", eye=dict(lid="sleepy"), bh=1.05),
    "King": dict(limbs=[("arms",)], texture="cloth", back=king_back, front=king_front, mouth_kind="frown", eye=dict(lid="sleepy"), bw=1.05),
    "DJ": dict(limbs=[("arms", True)], front=dj_front, mouth_kind="grin", teeth=5, eye=dict(iris=hsv(0.5, 0.9, 0.9)), bw=0.95),
    "SpaceFence": dict(back=fence_back, front=fence_front, limbs=[("legs", 2)], texture="plates", mouth=False,
                       eye=dict(glow=hsv(0.5, 0.7, 1.0), iris=hsv(0.55, 0.9, 0.4))),
    "Spaceship": dict(body=saucer_body, back=saucer_back, front=saucer_front, mouth=False, eye_dy=-40, eye_scale=0.8,
                      eye=dict(iris=hsv(0.13, 0.9, 0.9)), bw=1.0, bh=1.0, armor=False, spec=0.6),
    "VRWorkout": dict(limbs=[("legs", 2), ("arms", True)], front=vr_front, mouth_kind="grin", teeth=7, bw=1.05, bh=0.95),
    "OldGranny": dict(limbs=[("legs", 2)], texture="cracks", front=granny_front, mouth_kind="frown", eye=dict(lid="sleepy", iris=hsv(0.6, 0.5, 0.6)), bh=0.95),
    "Albot": dict(limbs=[("arms",), ("legs", 2)], texture="metal", front=albot_front, mouth_kind="zigzag", teeth=5,
                  col=(150, 150, 165, 255), eye=dict(glow=RED, iris=(90, 0, 10, 255), lid=None), horns=False, spikes=False),
    "Jumper": dict(back=jumper_back, limbs=[("arms", True)], texture="spots", mouth_kind="grin", teeth=4, eye=dict(lid=None), dy=-40),
    "Giant": dict(limbs=[("legs", 2)], texture="cracks", col=hsv(0.08, 0.55, 0.72), front=giant_front, mouth_kind="zigzag", teeth=7, bw=1.15, bh=1.1, eye_scale=0.75, eye=dict(lid="angry")),
    "Gardener": dict(back=gardener_back, limbs=[("tentacles", 4)], texture="veins", mouth_kind="small", eye=dict(lid=None, iris=hsv(0.95, 0.7, 0.9))),
    "Army": dict(limbs=[("legs", 2), ("arms",)], texture="plates", front=army_front, mouth_kind="frown", eye=dict(lid="angry"), horns=False, bw=1.05),
    "Morpher": dict(back=morpher_back, front=morpher_front, limbs=[("tentacles", 3)], mouth_kind="small", eye=dict(lid=None), alpha=235),
    "Fusion": dict(front=fusion_front, eyes=False, mouth=False, limbs=[("legs", 2), ("arms",)], texture="veins", bw=1.1, bh=0.85, dy=40, armor=False),
    "CommonCrippler": dict(back=crippler_back, front=crippler_front, limbs=[("arms",)], texture="scales", mouth_kind="zigzag", teeth=6, eye=dict(lid="angry", slit=True)),
    "Splashfest": dict(back=splash_back, front=splash_front, texture="slime", mouth_kind="grin", teeth=5, eye=dict(lid=None), alpha=245, spec=0.6),
    "Virus": dict(back=virus_back, texture="veins", mouth_kind="zigzag", teeth=8, eye=dict(slit=True, lid=None, iris=hsv(0.13, 0.9, 0.9)), bw=0.95, bh=0.95),
    "Guardian": dict(back=guardian_back, front=guardian_front, texture="plates", mouth_kind="frown", horns=False, spikes=False,
                     eye=dict(glow=hsv(0.55, 0.7, 1.0), iris=hsv(0.6, 0.9, 0.4), lid="angry")),
    "DarkArts": dict(back=lambda k: hood_back(k, hsv(0.78, 0.7, 0.28)), front=dark_arts_front, mouth=False, horns=False, spikes=False, ring=True,
                     eye=dict(glow=hsv(0.78, 0.8, 1.0), iris=hsv(0.8, 0.9, 0.3), lid=None), armor=False),
    "Rare": dict(front=rare_front, texture=None, mouth_kind="zigzag", teeth=7, body=lambda cx, cy, bw, bh: soften(poly_mask([(cx - bw * 0.55, cy - bh), (cx + bw * 0.55, cy - bh), (cx + bw, cy - bh * 0.45), (cx + bw, cy + bh * 0.45), (cx + bw * 0.55, cy + bh), (cx - bw * 0.55, cy + bh), (cx - bw, cy + bh * 0.45), (cx - bw, cy - bh * 0.45)]), 4), limbs=[("legs", 2)], eye=dict(iris=hsv(0.13, 0.9, 0.9), lid="angry"), spec=0.6, bw=0.95),
    "Protected": dict(front=bunker_front, texture="plates", eyes=False, mouth=False, bw=1.1, bh=0.95, armor=False),
    "Interdimentional": dict(back=interdim_back, texture=None, mouth_kind="small", alpha=210, eye=dict(glow=hsv(0.7, 0.6, 1.0), iris=hsv(0.75, 0.9, 0.4), lid=None), armor=False),
    "Scarce": dict(front=scarce_front, limbs=[("arms",), ("legs", 2)], texture="plates", mouth_kind="zigzag", teeth=7, eye=dict(iris=hsv(0.13, 0.9, 0.9)), bw=1.1, bh=1.05),
    "TheHevalGod": dict(back=hevalgod_back, front=hevalgod_front, limbs=[("arms", True)], texture="scales", mouth=False,
                        eye=dict(glow=hsv(0.12, 0.9, 1.0), iris=hsv(0.02, 0.9, 0.5)), bw=1.1, bh=1.1, spikes=False),
    "GodOfSpace": dict(back=gos_back, front=gos_front, texture="spots", mouth_kind="grin", teeth=7, eye=dict(glow=hsv(0.13, 0.7, 1.0), iris=hsv(0.6, 0.9, 0.4)),
                       bw=1.05, bh=1.05, spikes=False, horns=True),
    "Swarmling": dict(back=swarm_back, front=swarm_front, mouth=False, texture="spots", eye=dict(lid=None, iris=hsv(0.13, 0.9, 0.9)), bw=0.8, bh=0.9, eye_dy=-20),
    "Shieldbearer": dict(front=shieldbearer_front, limbs=[("legs", 2)], texture="plates", mouth_kind="frown", eye=dict(lid="angry")),
    "Phaser": dict(back=phaser_back, front=phaser_front, limbs=[("tentacles", 3)], alpha=150, mouth_kind="small", eye=dict(glow=hsv(0.5, 0.6, 1.0), iris=hsv(0.5, 0.9, 0.4), lid=None), spec=0.5),
    "Medic": dict(front=medic_front, limbs=[("legs", 2), ("arms",)], mouth_kind="small", eye=dict(lid=None, iris=hsv(0.6, 0.7, 0.8)), col=hsv(0.0, 0.18, 0.95), armor=False),
    "Thief": dict(front=thief_front, limbs=[("legs", 2), ("arms",)], eyes=False, mouth_kind="grin", teeth=4, texture="cloth"),
    "Splitter": dict(front=splitter_front, limbs=[("legs", 2), ("arms",)], texture="scales", mouth_kind="zigzag", teeth=6, eye=dict(lid=None), mouth_dy=30),
    "Anchor": dict(front=anchor_front, texture="metal", mouth_kind="frown", eye=dict(lid="angry", iris=hsv(0.13, 0.8, 0.9)), bw=1.05, bh=1.05, eye_dy=-30, mouth_dy=-25),
    "Necromancer": dict(back=lambda k: hood_back(k, hsv(0.82, 0.6, 0.25)), front=necro_front, mouth_kind="zigzag", teeth=5, horns=False, spikes=False,
                        eye=dict(glow=hsv(0.35, 0.9, 1.0), iris=hsv(0.35, 0.9, 0.3), lid=None), armor=False),
    "VoidTitan": dict(front=titan_front, limbs=[("legs", 2), ("arms",)], texture="plates", mouth_kind="zigzag", teeth=9, bw=1.2, bh=1.15,
                      eye=dict(glow=hsv(0.72, 0.7, 1.0), iris=hsv(0.72, 0.9, 0.3)), eye_dy=-30, mouth_dy=-50),
}

# ----------------------------------------------------------------- main ---

def contact_sheet(aliens, cell=150, cols=6):
    rows = (len(aliens) + cols - 1) // cols
    pad = 8
    sheet = Image.new("RGBA", (cols * (cell + pad) + pad, rows * (cell + 30 + pad) + pad), (10, 14, 26, 255))
    d = ImageDraw.Draw(sheet)
    try:
        f = ImageFont.truetype("arial.ttf", 15)
    except OSError:
        f = ImageFont.load_default()
    for i, al in enumerate(aliens):
        x = pad + (i % cols) * (cell + pad)
        y = pad + (i // cols) * (cell + 30 + pad)
        d.rounded_rectangle((x, y, x + cell, y + cell + 30), 8, fill=(22, 30, 51, 255))
        im = Image.open(os.path.join(OUT, al["key"] + ".png")).resize((cell, cell), Image.LANCZOS)
        sheet.alpha_composite(im, (x, y))
        small = Image.open(os.path.join(OUT, al["key"] + ".png")).resize((40, 40), Image.LANCZOS)
        sheet.alpha_composite(small, (x + cell - 44, y + cell - 10))
        d.text((x + 6, y + cell + 6), al["title"], font=f, fill=(238, 242, 250, 255))
    return sheet


def main(only=None):
    with open(os.path.join(HERE, "data.json"), encoding="utf-8") as fh:
        aliens = json.load(fh)["aliens"]
    os.makedirs(OUT, exist_ok=True)
    for al in aliens:
        if only and al["key"] not in only:
            continue
        im = build(al)
        assert im.size == (256, 256) and im.mode == "RGBA" and im.getpixel((0, 0))[3] == 0 and im.getbbox(), al["key"]
        im.save(os.path.join(OUT, al["key"] + ".png"))
        print("wrote", al["key"])
    contact_sheet(aliens).save(os.path.join(OUT, "sheet.png"))
    print("wrote sheet.png")


if __name__ == "__main__":
    import sys
    main(sys.argv[1:] or None)
