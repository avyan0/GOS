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
OUT = os.path.join(ROOT, "assets", "img", "aliens")
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
