"""Procedural weapon icons for Gods of Space.

    python tools/art/gen_weapons.py

Writes assets/img/weapons/<id>.png (256x256 RGBA) and sheet.png.
Everything is drawn at 3x and downsampled for anti-aliasing. Deterministic.
"""
import json, math, os, random, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageChops, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = json.load(open(os.path.join(ROOT, "tools", "art", "data.json")))
OUT = os.path.join(ROOT, "tools", "art", "src", "weapons")  # high-res source; pixelize.py makes the game assets
SIZE, S = 256, 3
N = SIZE * S
WHITE, BLACK = (255, 255, 255), (0, 0, 0)
INK = (6, 9, 18)          # outline colour
PANEL = (0x16, 0x1E, 0x33)

# ---------------------------------------------------------------- colour
def hexrgb(h): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))
def mix(a, b, t): return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))

def palette(rar):
    m = hexrgb(DATA["rarityColors"][rar])
    grey = (150, 160, 182)
    return dict(main=m, bright=mix(m, WHITE, 0.5), core=mix(m, WHITE, 0.85),
                deep=mix(m, BLACK, 0.45), dark=mix(m, BLACK, 0.7),
                metal=mix(mix(m, grey, 0.8), BLACK, 0.15), metal_dark=mix(mix(m, grey, 0.8), BLACK, 0.55),
                gun=mix(mix(m, grey, 0.85), BLACK, 0.4))

# ---------------------------------------------------------------- geometry (256-space)
def P(pts): return [(x * S, y * S) for x, y in pts]
def rot(pts, ang, c=(128, 128)):
    a = math.radians(ang); ca, sa = math.cos(a), math.sin(a)
    return [(c[0] + (x - c[0]) * ca - (y - c[1]) * sa, c[1] + (x - c[0]) * sa + (y - c[1]) * ca) for x, y in pts]
def star_pts(c, ro, ri, n, phase=-90):
    out = []
    for i in range(2 * n):
        r = ro if i % 2 == 0 else ri
        a = math.radians(phase + i * 180 / n)
        out.append((c[0] + r * math.cos(a), c[1] + r * math.sin(a)))
    return out
def arc_pts(c, r, a0, a1, n=24):
    return [(c[0] + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)),
             c[1] + r * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]
def lerp_pt(a, b, t): return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
def band(pts, w0, w1=None):
    """Polygon of a stroked polyline with linearly varying width."""
    if w1 is None: w1 = w0
    L, R = [], []
    n = len(pts) - 1
    for i, (x, y) in enumerate(pts):
        a = pts[max(i - 1, 0)]; b = pts[min(i + 1, n)]
        dx, dy = b[0] - a[0], b[1] - a[1]; l = math.hypot(dx, dy) or 1
        nx, ny = -dy / l, dx / l
        w = (w0 + (w1 - w0) * i / max(n, 1)) / 2
        L.append((x + nx * w, y + ny * w)); R.append((x - nx * w, y - ny * w))
    return L + R[::-1]

# ---------------------------------------------------------------- masks (L images at 3x)
def new_mask(): return Image.new("L", (N, N), 0)
def m_poly(pts):
    m = new_mask(); ImageDraw.Draw(m).polygon(P(pts), fill=255); return m
def m_ellipse(c, rx, ry=None):
    ry = rx if ry is None else ry
    m = new_mask(); ImageDraw.Draw(m).ellipse(P([(c[0] - rx, c[1] - ry), (c[0] + rx, c[1] + ry)]), fill=255); return m
def m_line(pts, w):
    m = new_mask(); d = ImageDraw.Draw(m)
    d.line(P(pts), fill=255, width=int(w * S), joint="curve")
    for x, y in pts:  # round caps
        d.ellipse(P([(x - w / 2, y - w / 2), (x + w / 2, y + w / 2)]), fill=255)
    return m
def m_arc(c, r, a0, a1, w):
    m = new_mask()
    ImageDraw.Draw(m).arc(P([(c[0] - r, c[1] - r), (c[0] + r, c[1] + r)]), a0, a1, fill=255, width=int(w * S))
    return m
def m_union(*ms):
    out = ms[0]
    for m in ms[1:]: out = ImageChops.lighter(out, m)
    return out
def m_sub(a, b): return ImageChops.subtract(a, b)
def m_and(a, b): return ImageChops.darker(a, b)
def dilate(m, px): return m.filter(ImageFilter.GaussianBlur(px * S * 0.9)).point(lambda v: 255 if v > 60 else 0)
def shift(m, dx, dy): return ImageChops.offset(m, int(dx * S), int(dy * S))

# ---------------------------------------------------------------- canvas
class Canvas:
    def __init__(self, rar, seed):
        self.im = Image.new("RGBA", (N, N), (0, 0, 0, 0))
        self.p = palette(rar); self.rar = rar; self.rng = random.Random(seed)

    # -- primitive compositing
    def paste(self, layer): self.im.alpha_composite(layer)
    def fill(self, mask, col, alpha=1.0):
        layer = Image.new("RGBA", (N, N), col + (0,))
        a = mask if alpha >= 1 else mask.point(lambda v: int(v * alpha))
        layer.putalpha(a); self.paste(layer)

    def shape(self, mask, col=None, light=None, dark=None, bevel=1.6, outline=1.2, sphere=None, contrast=0.55):
        """Shaded solid: gradient lit from upper-left, bevel rim, dark outline."""
        col = col or self.p["main"]
        light = light or mix(col, WHITE, contrast * 0.6)
        dark = dark or mix(col, BLACK, contrast)
        bb = mask.getbbox()
        if not bb: return
        if outline: self.fill(dilate(mask, outline), INK, 0.9)
        x0, y0, x1, y1 = bb
        yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
        if sphere:
            (cx, cy), r = sphere; cx, cy, r = cx * S, cy * S, r * S
            t = np.hypot(xx - (cx - 0.35 * r), yy - (cy - 0.35 * r)) / (1.45 * r)
        else:
            t = ((xx - x0) + (yy - y0)) / max((x1 - x0) + (y1 - y0), 1)
        t = np.clip(t, 0, 1)[..., None]
        rgb = np.array(light, np.float32) * (1 - t) + np.array(dark, np.float32) * t
        arr = np.zeros((N, N, 4), np.uint8); arr[..., :3] = rgb.astype(np.uint8); arr[..., 3] = np.array(mask)
        self.paste(Image.fromarray(arr, "RGBA"))
        if bevel:
            hi = m_sub(mask, shift(mask, bevel, bevel)); self.fill(hi, WHITE, 0.55)
            lo = m_sub(mask, shift(mask, -bevel, -bevel)); self.fill(lo, BLACK, 0.45)

    # -- shape sugar
    def poly(self, pts, **kw): self.shape(m_poly(pts), **kw)
    def circle(self, c, r, **kw): self.shape(m_ellipse(c, r), sphere=(c, r), **kw)
    def ellipse(self, c, rx, ry, **kw): self.shape(m_ellipse(c, rx, ry), **kw)
    def ring(self, c, r, w, **kw): self.shape(m_sub(m_ellipse(c, r + w / 2), m_ellipse(c, r - w / 2)), **kw)
    def arc(self, c, r, a0, a1, w, **kw): self.shape(m_arc(c, r, a0, a1, w), **kw)
    def bar(self, pts, w, **kw): self.shape(m_line(pts, w), **kw)

    # -- fx
    def glow(self, mask, col=None, r=10, strength=0.8):
        col = col or self.p["main"]
        a = mask.filter(ImageFilter.GaussianBlur(r * S))
        self.fill(a, col, strength)
    def glow_circle(self, c, r, col=None, blur=10, strength=0.8): self.glow(m_ellipse(c, r), col, blur, strength)
    def beam(self, pts, w, col=None, core=True, halo=2.6):
        col = col or self.p["main"]
        self.glow(m_line(pts, w * halo), col, w * 0.9, 0.7)
        self.fill(m_line(pts, w), col)
        if core: self.fill(m_line(pts, w * 0.42), mix(col, WHITE, 0.85))
    def sparkle(self, c, size, col=None, thin=0.22, glow=True):
        col = col or self.p["core"]
        m = m_poly(star_pts(c, size, size * thin, 4))
        if glow: self.glow(m, self.p["main"], size * 0.5, 0.9)
        self.fill(m, col)
        self.fill(m_ellipse(c, size * 0.18), WHITE)
    def trail(self, a, b, w, col=None, soft=2, strength=0.9):
        """Tapered streak from a (wide) to b (point)."""
        col = col or self.p["main"]
        m = m_poly(band([a, b], w, 0.5)).filter(ImageFilter.GaussianBlur(soft * S))
        arr = np.array(m, np.float32)
        yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
        ax, ay, bx, by = a[0] * S, a[1] * S, b[0] * S, b[1] * S
        t = ((xx - ax) * (bx - ax) + (yy - ay) * (by - ay)) / (((bx - ax) ** 2 + (by - ay) ** 2) or 1)
        arr *= np.clip(1 - t, 0, 1) * strength
        self.fill(Image.fromarray(arr.astype(np.uint8)), col)
        self.fill(Image.fromarray((arr * 0.5).astype(np.uint8)), mix(col, WHITE, 0.6))
    def bolt(self, pts, w, col=None):
        """Zig-zag lightning: glow + tapered body + bright core."""
        col = col or self.p["bright"]
        m = m_poly(band(pts, w, w * 0.25))
        self.glow(m, self.p["main"], 6, 0.9)
        self.fill(dilate(m, 1.0), INK, 0.85)
        self.fill(m, col)
        self.fill(m_poly(band(pts, w * 0.4, w * 0.08)), WHITE, 0.9)
    def embers(self, n, box=(20, 20, 236, 236), col=None, rmax=3.5):
        col = col or self.p["bright"]
        for _ in range(n):
            x = self.rng.uniform(box[0], box[2]); y = self.rng.uniform(box[1], box[3]); r = self.rng.uniform(1.2, rmax)
            self.glow_circle((x, y), r, self.p["main"], 4, 0.9)
            self.fill(m_ellipse((x, y), r), mix(col, WHITE, 0.5))
    def speedlines(self, pts_pairs, w=3, col=None):
        for a, b in pts_pairs: self.trail(a, b, w, col, soft=0.8, strength=0.8)

    # -- finish: rarity aura + outline + downsample
    def finish(self):
        body = self.im
        alpha = body.getchannel("A")
        grand = {"common": 0.45, "rare": 0.6, "scarce": 0.75, "god": 1.0}[self.rar]
        out = Image.new("RGBA", (N, N), (0, 0, 0, 0))
        aura = alpha.filter(ImageFilter.GaussianBlur(14 * S)).point(lambda v: int(min(255, v * 1.6) * 0.55 * grand))
        l = Image.new("RGBA", (N, N), self.p["main"] + (0,)); l.putalpha(aura); out.alpha_composite(l)
        if self.rar == "god":
            aura2 = alpha.filter(ImageFilter.GaussianBlur(5 * S)).point(lambda v: int(min(255, v * 1.5) * 0.5))
            l = Image.new("RGBA", (N, N), self.p["bright"] + (0,)); l.putalpha(aura2); out.alpha_composite(l)
        ol = alpha.filter(ImageFilter.GaussianBlur(1.3 * S)).point(lambda v: 255 if v > 30 else 0)
        l = Image.new("RGBA", (N, N), INK + (0,)); l.putalpha(ol.point(lambda v: int(v * 0.85))); out.alpha_composite(l)
        out.alpha_composite(body)
        return out.resize((SIZE, SIZE), Image.LANCZOS)

# ---------------------------------------------------------------- shared motifs
def crosshair(c, c_, r, w=5):
    c.ring(c_, r, w)
    for a in range(0, 360, 90):
        p = rot([(c_[0] + r - 6, c_[1]), (c_[0] + r + 9, c_[1])], a, c_)
        c.bar(p, w)
    c.fill(m_ellipse(c_, r * 0.22), c.p["core"])

def rock(c, ctr, r, seed, col=None):
    rng = random.Random(seed)
    pts = [(ctr[0] + r * rng.uniform(0.72, 1.0) * math.cos(math.radians(a)),
            ctr[1] + r * rng.uniform(0.72, 1.0) * math.sin(math.radians(a))) for a in range(0, 360, 45)]
    c.poly(pts, col=col or c.p["metal"], contrast=0.7)
    for _ in range(2):
        px = ctr[0] + rng.uniform(-0.4, 0.4) * r; py = ctr[1] + rng.uniform(-0.4, 0.4) * r
        c.fill(m_ellipse((px, py), r * 0.16), c.p["metal_dark"])

def smooth(pts, n=2):
    """Chaikin corner cutting on a closed polygon."""
    for _ in range(n):
        out = []
        for i in range(len(pts)):
            a, b = pts[i], pts[(i + 1) % len(pts)]
            out.append(lerp_pt(a, b, 0.25)); out.append(lerp_pt(a, b, 0.75))
        pts = out
    return pts

def scale_pts(pts, sx, sy, c=(128, 128)): return [(c[0] + (x - c[0]) * sx, c[1] + (y - c[1]) * sy) for x, y in pts]

def teardrop(ctr, w, h, tilt=0, n=48):
    """Pointy-top teardrop; ctr is the centre, w/h half sizes; tilted about its base."""
    pts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        pts.append((ctr[0] + w * math.sin(a) * math.sin(a / 2) ** 0.8, ctr[1] - h * math.cos(a) * 0.85 + h * 0.15))
    return rot(pts, tilt, (ctr[0], ctr[1] + h))

FLAME = smooth([(128, 238), (96, 232), (70, 206), (64, 170), (68, 140), (50, 116), (48, 86), (70, 104), (84, 90), (92, 58),
                (104, 30), (112, 62), (122, 44), (134, 14), (146, 50), (154, 78), (170, 60), (192, 44), (186, 84), (194, 112),
                (196, 150), (188, 192), (170, 224), (150, 236)], 1)
FLAME_IN = smooth([(128, 238), (104, 230), (90, 206), (92, 176), (84, 150), (96, 160), (106, 132), (110, 104), (122, 130),
                   (130, 96), (140, 128), (152, 112), (150, 150), (166, 170), (168, 200), (156, 226)], 1)

def flame(c, base, scale=1.0, col_out=None, col_mid=None, col_in=None):
    """Hand-drawn licking flame; base = bottom centre (x, y)."""
    def at(pts, k, dy=0):
        return m_poly([(base[0] + (x - 128) * k * scale, base[1] + (y - 238) * k * scale + dy) for x, y in pts])
    c.glow(at(FLAME, 1.0), c.p["main"], 10, 0.6)
    c.shape(at(FLAME, 1.0), col=col_out or c.p["main"], contrast=0.5)
    c.fill(at(FLAME_IN, 1.0), col_mid or c.p["bright"])
    c.fill(at(FLAME_IN, 0.5, -4), col_in or WHITE, 0.95)

def sword(c, hilt, tip, blade_w, col=None, guard=18):
    """Straight blade from hilt point to tip, with crossguard + grip."""
    hx, hy = hilt; tx, ty = tip
    dx, dy = tx - hx, ty - hy; L = math.hypot(dx, dy); ux, uy = dx / L, dy / L; nx, ny = -uy, ux
    g = (hx + ux * 22, hy + uy * 22)
    blade = [(g[0] + nx * blade_w / 2, g[1] + ny * blade_w / 2), (tx - ux * blade_w, ty - uy * blade_w),
             (tx, ty), (tx - ux * blade_w, ty - uy * blade_w), (g[0] - nx * blade_w / 2, g[1] - ny * blade_w / 2)]
    blade = [blade[0], (tx - ux * 20 + nx * blade_w / 2, ty - uy * 20 + ny * blade_w / 2), (tx, ty),
             (tx - ux * 20 - nx * blade_w / 2, ty - uy * 20 - ny * blade_w / 2), blade[4]]
    c.poly(blade, col=col or c.p["metal"], contrast=0.65)
    # fuller
    c.fill(m_line([lerp_pt(g, tip, 0.1), lerp_pt(g, tip, 0.8)], blade_w * 0.18), mix(c.p["main"], WHITE, 0.4), 0.8)
    c.bar([(g[0] + nx * guard, g[1] + ny * guard), (g[0] - nx * guard, g[1] - ny * guard)], 8, col=c.p["deep"])
    c.bar([hilt, (g[0] - ux * 3, g[1] - uy * 3)], 9, col=c.p["gun"])
    c.circle((hx - ux * 2, hy - uy * 2), 6, col=c.p["main"])

def skull(c, ctr, r, col=None):
    cx, cy = ctr; col = col or c.p["core"]
    c.circle((cx, cy - r * 0.15), r, col=col, contrast=0.5)
    c.poly([(cx - r * 0.78, cy + r * 0.05), (cx + r * 0.78, cy + r * 0.05), (cx + r * 0.6, cy + r * 0.55), (cx + r * 0.46, cy + r * 0.95),
            (cx - r * 0.46, cy + r * 0.95), (cx - r * 0.6, cy + r * 0.55)], col=col, contrast=0.5)
    for sx in (-1, 1):
        c.fill(m_ellipse((cx + sx * r * 0.36, cy - r * 0.08), r * 0.3, r * 0.32), INK)
        c.fill(m_ellipse((cx + sx * r * 0.34, cy - r * 0.16), r * 0.1, r * 0.1), c.p["main"])
    c.fill(m_poly([(cx, cy + r * 0.2), (cx - r * 0.13, cy + r * 0.45), (cx + r * 0.13, cy + r * 0.45)]), INK)
    for i in range(-2, 3):
        c.fill(m_line([(cx + i * r * 0.2, cy + r * 0.62), (cx + i * r * 0.2, cy + r * 0.92)], 2), INK, 0.8)
    c.fill(m_line([(cx - r * 0.5, cy + r * 0.62), (cx + r * 0.5, cy + r * 0.62)], 2), INK, 0.8)

def emitter(c, ctr, ang, size=1.0):
    """Boxy laser emitter body pointing along ang (degrees)."""
    s = size
    body = rot([(ctr[0] - 40 * s, ctr[1] - 20 * s), (ctr[0] + 20 * s, ctr[1] - 20 * s), (ctr[0] + 34 * s, ctr[1] - 9 * s),
                (ctr[0] + 34 * s, ctr[1] + 9 * s), (ctr[0] + 20 * s, ctr[1] + 20 * s), (ctr[0] - 40 * s, ctr[1] + 20 * s)], ang, ctr)
    c.poly(body, col=c.p["gun"], contrast=0.6)
    fin = rot([(ctr[0] - 30 * s, ctr[1] - 20 * s), (ctr[0] - 10 * s, ctr[1] - 20 * s), (ctr[0] - 18 * s, ctr[1] - 32 * s),
               (ctr[0] - 34 * s, ctr[1] - 32 * s)], ang, ctr)
    c.poly(fin, col=c.p["metal_dark"])
    slot = rot([(ctr[0] - 30 * s, ctr[1] - 4 * s), (ctr[0] + 10 * s, ctr[1] - 4 * s), (ctr[0] + 10 * s, ctr[1] + 4 * s),
                (ctr[0] - 30 * s, ctr[1] + 4 * s)], ang, ctr)
    c.fill(m_poly(slot), c.p["main"]); c.glow(m_poly(slot), c.p["main"], 3, 0.8)
    muzzle = rot([(ctr[0] + 34 * s, ctr[1])], ang, ctr)[0]
    c.glow_circle(muzzle, 10 * s, c.p["bright"], 6, 1.0)
    return muzzle

# ---------------------------------------------------------------- recipes
R = {}
def recipe(name):
    def deco(f): R[name] = f; return f
    return deco

# ---- COMMON -------------------------------------------------------------
@recipe("AstroidRain")
def _(c):
    rocks = [((152, 164), 40, 1), ((70, 92), 26, 2), ((196, 62), 20, 3), ((64, 200), 15, 4)]
    for ctr, r, sd in rocks:
        c.trail(ctr, (ctr[0] - r * 3.2, ctr[1] - r * 3.2), r * 1.9, strength=1.0, soft=3)
    for ctr, r, sd in rocks:
        c.glow_circle(ctr, r * 1.1, c.p["main"], 8, 0.8)
        rock(c, ctr, r, sd, col=mix(c.p["metal"], c.p["main"], 0.25))
        c.fill(m_sub(m_ellipse(ctr, r * 0.98), m_ellipse((ctr[0] - r * 0.3, ctr[1] - r * 0.3), r * 1.05)), c.p["bright"], 0.75)
    c.sparkle((30, 40), 9); c.sparkle((228, 150), 7)

@recipe("PoisonArrow")
def _(c):
    a, b, tip = (44, 44), (186, 186), (222, 222)
    c.bar([a, b], 14, col=c.p["gun"], contrast=0.6)
    for k in (0, 22):
        p = (a[0] + k, a[1] + k)
        c.poly([p, (p[0] - 22, p[1] + 8), (p[0] + 4, p[1] + 30)], col=c.p["main"], contrast=0.5)
        c.poly([p, (p[0] + 8, p[1] - 22), (p[0] + 30, p[1] + 4)], col=c.p["main"], contrast=0.5)
    head = [(b[0] - 52, b[1] - 10), (b[0] - 14, b[1] - 14), (b[0] - 10, b[1] - 52), tip]
    c.glow(m_poly(head), c.p["main"], 10, 0.9)
    c.poly(head, col=c.p["bright"], contrast=0.6)
    c.fill(m_poly([(b[0] - 30, b[1] - 12), tip, (b[0] - 12, b[1] - 30)]), WHITE, 0.35)
    for (x, y, r) in ((160, 216, 9), (216, 160, 8), (190, 240, 6)):
        drop = m_union(m_poly([(x, y - r * 2.2), (x + r * 0.9, y), (x - r * 0.9, y)]), m_ellipse((x, y + r * 0.1), r))
        c.glow(drop, c.p["main"], 4, 0.8); c.shape(drop, col=c.p["main"], contrast=0.45)
        c.fill(m_ellipse((x - r * 0.3, y - r * 0.1), r * 0.3), WHITE, 0.85)

@recipe("TripleThreat")
def _(c):
    for ctr in ((128, 70), (74, 168), (182, 168)):
        c.glow_circle(ctr, 44, c.p["main"], 8, 0.5)
    for ctr in ((128, 70), (74, 168), (182, 168)):
        crosshair(c, ctr, 40, 7)

@recipe("CosmicFire")
def _(c):
    flame(c, (128, 238), 1.0)
    for (x, y, r) in ((70, 80, 5), (190, 60, 6), (176, 110, 4)):
        c.fill(m_ellipse((x, y), r), c.p["bright"]); c.glow_circle((x, y), r, c.p["main"], 4, 0.9)

@recipe("Astrobolt")
def _(c):
    pts = [(156, 16), (76, 126), (128, 126), (92, 240), (188, 104), (136, 104), (176, 16)]
    c.glow(m_poly(pts), c.p["main"], 14, 0.9)
    c.poly(pts, col=c.p["bright"], contrast=0.55)
    c.fill(m_poly([(150, 34), (100, 112), (128, 112), (116, 150), (160, 100), (140, 100), (160, 34)]), WHITE, 0.55)
    for ctr in ((52, 60), (204, 190)):
        c.sparkle(ctr, 14)

@recipe("StarBlast")
def _(c):
    c.glow_circle((128, 128), 70, c.p["main"], 16, 0.7)
    for a in range(0, 360, 90):
        c.poly(rot([(128, 128 - 20), (128 + 12, 128 - 20), (128 + 14, 128 - 82), (128, 128 - 110), (128 - 14, 128 - 82), (128 - 12, 128 - 20)], a), col=c.p["main"])
    c.poly(star_pts((128, 128), 42, 18, 4, -45), col=c.p["bright"], contrast=0.5)
    c.fill(m_ellipse((128, 128), 12), WHITE)

@recipe("LaserKill")
def _(c):
    c.beam([(104, 104), (226, 226)], 16, halo=2.8)
    c.fill(m_line([(104, 104), (226, 226)], 4), WHITE)
    c.sparkle((228, 228), 22, thin=0.16)
    c.sparkle((166, 150), 9, glow=False)
    emitter(c, (68, 68), 45, 1.35)

@recipe("StellarBoost")
def _(c):
    c.trail((128, 120), (128, 250), 70, strength=0.9, soft=4)
    c.glow(m_poly([(128, 24), (216, 110), (40, 110)]), c.p["main"], 14, 0.6)
    arrow = [(128, 16), (222, 106), (170, 106), (170, 150), (86, 150), (86, 106), (34, 106)]
    c.poly(arrow, col=c.p["main"], contrast=0.5)
    c.fill(m_poly([(128, 38), (152, 62), (104, 62)]), WHITE, 0.45)
    c.sparkle((128, 96), 18, glow=False)
    for ctr, sz in (((128, 176), 16), ((100, 196), 11), ((156, 204), 12), ((124, 226), 8), ((146, 236), 5), ((92, 230), 5)):
        c.sparkle(ctr, sz)
    for ctr, sz in (((36, 44), 12), ((222, 40), 10), ((200, 20), 7), ((22, 88), 6)):
        c.sparkle(ctr, sz)

@recipe("GravityWell")
def _(c):
    ctr = (128, 128)
    c.glow_circle(ctr, 80, c.p["main"], 20, 0.6)
    for k in range(3):
        pts = []
        for i in range(60):
            t = i / 59; a = math.radians(k * 120 + t * 420); r = 108 * (1 - t) ** 1.1 + 12
            pts.append((ctr[0] + r * math.cos(a), ctr[1] + r * math.sin(a)))
        c.poly(band(pts, 22, 4), col=mix(c.p["main"], WHITE, 0.1), contrast=0.5)
    c.glow_circle(ctr, 30, c.p["bright"], 8, 0.9)
    c.fill(m_ellipse(ctr, 28), INK)
    c.fill(m_sub(m_ellipse(ctr, 28), m_ellipse(ctr, 23)), c.p["core"], 0.95)

@recipe("Ricochet")
def _(c):
    c.poly([(20, 30), (44, 30), (44, 226), (20, 226)], col=c.p["metal"], contrast=0.6)
    c.poly([(212, 30), (236, 30), (236, 226), (212, 226)], col=c.p["metal"], contrast=0.6)
    path = [(44, 60), (212, 110), (44, 160), (196, 206)]
    c.beam(path, 9, halo=2.0)
    for p, r in ((path[0], 5), (path[1], 7), (path[2], 8)):
        c.sparkle(p, r * 2.2, glow=False)
    c.circle(path[3], 17, col=c.p["bright"], contrast=0.5)
    c.glow_circle(path[3], 18, c.p["main"], 8, 0.9)

@recipe("Scanner")
def _(c):
    ctr = (128, 132)
    c.fill(m_ellipse(ctr, 100), mix(c.p["dark"], BLACK, 0.5), 0.9)
    c.ring(ctr, 100, 8, col=c.p["metal"], contrast=0.6)
    for r in (66, 33): c.fill(m_sub(m_ellipse(ctr, r + 1.5), m_ellipse(ctr, r - 1.5)), c.p["main"], 0.5)
    c.fill(m_line([(ctr[0] - 96, ctr[1]), (ctr[0] + 96, ctr[1])], 2.5), c.p["main"], 0.4)
    c.fill(m_line([(ctr[0], ctr[1] - 96), (ctr[0], ctr[1] + 96)], 2.5), c.p["main"], 0.4)
    # sweep wedge with fading alpha
    wedge = m_poly([ctr] + arc_pts(ctr, 96, -90, -20, 18))
    arr = np.array(wedge, np.float32)
    yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
    ang = (np.degrees(np.arctan2(yy - ctr[1] * S, xx - ctr[0] * S)) + 90) % 360
    arr *= np.clip(ang / 70, 0, 1) ** 1.2
    c.fill(Image.fromarray(arr.astype(np.uint8)), c.p["bright"])
    c.beam([ctr, arc_pts(ctr, 96, -20, -20, 1)[0]], 6)
    for p in ((88, 96), (166, 176), (72, 168)):
        c.glow_circle(p, 5, c.p["bright"], 5, 1.0); c.fill(m_ellipse(p, 5.5), c.p["core"])
    c.circle(ctr, 9, col=c.p["bright"])

# ---- RARE ---------------------------------------------------------------
@recipe("ThunderStrike")
def _(c):
    ctr = (128, 84)
    for pts in ([(96, 128), (70, 176), (96, 170), (62, 234)], [(160, 128), (186, 178), (160, 172), (194, 234)],
                [(128, 140), (114, 196), (140, 188), (120, 246)]):
        c.bolt(pts, 16)
    c.glow_circle(ctr, 64, c.p["main"], 16, 0.9)
    c.circle(ctr, 62, col=c.p["main"], contrast=0.6)
    c.fill(m_ellipse((ctr[0] - 18, ctr[1] - 22), 24, 14), WHITE, 0.3)
    c.fill(m_ellipse(ctr, 40), mix(c.p["dark"], BLACK, 0.3), 0.7)
    c.bolt([(146, 40), (110, 88), (138, 86), (108, 134)], 12, col=WHITE)
    c.sparkle((44, 60), 10); c.sparkle((212, 50), 8)

@recipe("BattleRam")
def _(c):
    c.speedlines([((14, 100), (70, 100)), ((14, 128), (84, 128)), ((14, 156), (70, 156))], 6)
    # impact burst behind the head
    c.glow_circle((222, 128), 40, c.p["main"], 14, 0.8)
    c.poly(star_pts((226, 128), 52, 20, 9, -90), col=c.p["bright"], contrast=0.4, outline=0.9)
    # log with iron bands
    c.bar([(52, 128), (150, 128)], 42, col=c.p["gun"], contrast=0.6)
    for x in (78, 118): c.poly([(x - 7, 104), (x + 7, 104), (x + 7, 152), (x - 7, 152)], col=c.p["metal_dark"], contrast=0.6)
    c.fill(m_line([(58, 114), (140, 114)], 4), WHITE, 0.2)
    # heavy head
    head = [(140, 78), (196, 78), (216, 98), (216, 158), (196, 178), (140, 178)]
    c.poly(head, col=c.p["metal"], contrast=0.7)
    for y in (98, 128, 158): c.poly([(214, y - 10), (236, y), (214, y + 10)], col=c.p["bright"], contrast=0.5)
    for (x, y) in ((156, 96), (196, 96), (156, 160), (196, 160)):
        c.fill(m_ellipse((x, y), 5), c.p["metal_dark"]); c.fill(m_ellipse((x - 1.5, y - 1.5), 2), WHITE, 0.6)
    c.fill(m_poly([(146, 116), (206, 116), (206, 140), (146, 140)]), c.p["main"], 0.9)
    c.glow(m_poly([(146, 116), (206, 116), (206, 140), (146, 140)]), c.p["main"], 5, 0.8)

@recipe("ElectroJolt")
def _(c):
    # tesla coil: base, ribbed column, toroid, arcs
    c.glow_circle((128, 70), 60, c.p["main"], 18, 0.7)
    c.poly([(70, 236), (186, 236), (176, 210), (80, 210)], col=c.p["metal_dark"], contrast=0.6)
    c.poly([(104, 210), (152, 210), (146, 96), (110, 96)], col=c.p["gun"], contrast=0.6)
    for y in range(110, 206, 16):
        c.fill(m_line([(106, y), (150, y)], 5), c.p["main"], 0.75)
    c.ellipse((128, 82), 56, 22, col=c.p["metal"], contrast=0.7)
    c.fill(m_ellipse((128, 78), 40, 10), mix(c.p["dark"], BLACK, 0.3), 0.8)
    c.circle((128, 70), 14, col=c.p["bright"])
    c.glow_circle((128, 70), 14, c.p["core"], 8, 1.0)
    c.bolt([(128, 62), (104, 42), (116, 30), (84, 8)], 8)
    c.bolt([(128, 62), (156, 44), (146, 30), (178, 10)], 8)
    c.bolt([(84, 82), (58, 74), (52, 92), (18, 90)], 6)
    c.bolt([(172, 82), (200, 76), (206, 94), (238, 92)], 6)
    c.bolt([(128, 60), (132, 40), (124, 26), (130, 8)], 5)
    for p in ((60, 130), (196, 130)): c.sparkle(p, 9)

@recipe("DaggerThrow")
def _(c):
    c.speedlines([((30, 200), (100, 130)), ((16, 170), (70, 116)), ((60, 236), (120, 176))], 5)
    sword(c, (50, 206), (228, 28), 44, guard=22)
    c.sparkle((214, 44), 12)

@recipe("Hevalstruck")
def _(c):
    hc = (156, 84)
    c.bar([(44, 236), hc], 18, col=c.p["gun"], contrast=0.6)
    for t in (0.12, 0.26, 0.4): c.fill(m_line([lerp_pt((44, 236), hc, t)] * 2, 20), c.p["metal_dark"], 0.9)
    head = rot([(96, 40), (216, 40), (226, 58), (226, 110), (216, 128), (96, 128), (86, 110), (86, 58)], -54, hc)
    c.glow(m_poly(head), c.p["main"], 10, 0.6)
    c.poly(head, col=c.p["metal"], contrast=0.7)
    strip = rot([(110, 72), (202, 72), (202, 96), (110, 96)], -54, hc)
    c.fill(m_poly(strip), c.p["main"], 0.95); c.glow(m_poly(strip), c.p["main"], 6, 0.9)
    for t in (0.3, 0.7): c.fill(m_ellipse(lerp_pt(strip[0], strip[1], t), 4), WHITE, 0.6)
    c.poly(star_pts((218, 30), 34, 12, 8), col=c.p["core"], outline=0.8, bevel=0)
    c.glow_circle((218, 30), 24, c.p["main"], 10, 0.9)
    c.sparkle((60, 120), 10, glow=False)

@recipe("RecursiveExplosion")
def _(c):
    ctr = (128, 128)
    c.glow_circle(ctr, 90, c.p["main"], 20, 0.8)
    c.poly(star_pts(ctr, 118, 62, 12, -90), col=c.p["main"], contrast=0.5)
    c.poly(star_pts(ctr, 76, 42, 10, 0), col=c.p["bright"], contrast=0.4, outline=0.8)
    c.poly(star_pts(ctr, 44, 24, 8, -90), col=c.p["core"], contrast=0.3, outline=0.8)
    c.fill(m_ellipse(ctr, 16), WHITE)
    for ctr2 in ((40, 44), (216, 200), (212, 46)):
        c.poly(star_pts(ctr2, 18, 8, 6), col=c.p["bright"], outline=0.8, bevel=0); c.glow_circle(ctr2, 12, c.p["main"], 6, 0.9)

@recipe("Dueltroid")
def _(c):
    c.glow_circle((128, 128), 60, c.p["main"], 14, 0.6)
    sword(c, (44, 212), (208, 40), 28, guard=16)
    sword(c, (212, 212), (48, 40), 28, guard=16)
    c.poly(star_pts((128, 120), 26, 11, 6), col=c.p["core"], outline=0.8, bevel=0)
    c.glow_circle((128, 120), 20, c.p["bright"], 8, 1.0)
    for p in ((60, 36), (196, 36)): c.sparkle(p, 10)

@recipe("FreshStart")
def _(c):
    ctr = (128, 128)
    for i in range(3):
        for j in range(3):
            c.poly([(94 + i * 24, 94 + j * 24), (112 + i * 24, 94 + j * 24), (112 + i * 24, 112 + j * 24), (94 + i * 24, 112 + j * 24)],
                   col=c.p["metal_dark"] if (i + j) % 2 else c.p["main"], contrast=0.5)
    a0, a1 = 200, 470
    c.glow(m_arc(ctr, 92, a0, a1, 22), c.p["main"], 10, 0.7)
    c.arc(ctr, 92, a0, a1, 22, col=c.p["main"], contrast=0.55)
    p = (ctr[0] + 92 * math.cos(math.radians(a1)), ctr[1] + 92 * math.sin(math.radians(a1)))
    head = rot([(p[0] + 36, p[1]), (p[0] - 12, p[1] - 32), (p[0] - 12, p[1] + 32)], a1 + 90, p)
    c.poly(head, col=c.p["bright"], contrast=0.5)
    c.sparkle((196, 60), 10)

@recipe("ChainLightning")
def _(c):
    nodes = [(128, 120), (36, 60), (220, 44), (52, 208), (206, 196)]
    c.bolt([(128, 10), (108, 60), (144, 66), (128, 120)], 22)
    c.bolt([(128, 120), (86, 96), (98, 78), (36, 60)], 14)
    c.bolt([(128, 120), (170, 92), (164, 70), (220, 44)], 14)
    c.bolt([(128, 120), (90, 152), (106, 172), (52, 208)], 13)
    c.bolt([(128, 120), (164, 158), (150, 178), (206, 196)], 13)
    for i, n in enumerate(nodes):
        r = 22 if i == 0 else 16
        c.glow_circle(n, r, c.p["main"], 8, 0.9); c.circle(n, r, col=c.p["bright"] if i == 0 else c.p["main"])
        c.fill(m_ellipse(n, r * 0.35), WHITE, 0.9)

@recipe("TimeWarp")
def _(c):
    ctr = (128, 128)
    c.glow_circle(ctr, 96, c.p["main"], 14, 0.5)
    c.circle(ctr, 100, col=c.p["gun"], contrast=0.6)
    c.fill(m_ellipse(ctr, 86), mix(c.p["dark"], BLACK, 0.4))
    for a in range(0, 360, 30):
        p = rot([(ctr[0], ctr[1] - 82), (ctr[0], ctr[1] - 70 if a % 90 else ctr[1] - 62)], a, ctr)
        c.fill(m_line(p, 4 if a % 90 else 6), c.p["main"])
    c.bar([ctr, (128, 66)], 9, col=c.p["bright"]); c.bar([ctr, (176, 148)], 9, col=c.p["bright"])
    c.circle(ctr, 9, col=c.p["core"])
    # crack
    crack = [(150, 22), (132, 86), (156, 120), (118, 168), (140, 236)]
    c.fill(m_line(crack, 7), INK); c.fill(m_line(crack, 3), c.p["bright"], 0.9)
    c.glow(m_line(crack, 4), c.p["bright"], 5, 0.9)
    for p in ((170, 60), (106, 200)): c.sparkle(p, 8, glow=False)

@recipe("Barricade")
def _(c):
    rows = [(226, 0), (186, 1), (146, 0), (106, 1), (66, 0)]
    for y, off in rows:
        for x in range(28 - (34 if off else 0), 240, 68):
            x0, x1 = max(x, 28), min(x + 62, 228)
            if x1 - x0 < 16: continue
            c.poly([(x0, y - 36), (x1, y - 36), (x1, y), (x0, y)], col=c.p["metal"], contrast=0.6)
            for rx in (x0 + 8, x1 - 8):
                c.fill(m_ellipse((rx, y - 18), 3.2), c.p["metal_dark"]); c.fill(m_ellipse((rx - 0.8, y - 18.8), 1.4), WHITE, 0.6)
    c.fill(m_poly([(28, 66), (228, 66), (228, 30), (28, 30)]), c.p["main"], 0.95)
    c.glow(m_poly([(28, 60), (228, 60), (228, 34), (28, 34)]), c.p["main"], 8, 0.8)
    for x in range(40, 228, 36): c.fill(m_poly([(x, 30), (x + 12, 30), (x + 6, 66), (x - 6, 66)]), WHITE, 0.35)

# ---- SCARCE -------------------------------------------------------------
@recipe("SantaAxe")
def _(c):
    c.bar([(128, 240), (128, 40)], 16, col=c.p["gun"], contrast=0.6)
    for t in (0.55, 0.65, 0.75): c.fill(m_line([lerp_pt((128, 240), (128, 40), t)] * 2, 18), c.p["metal_dark"], 0.9)
    for sx in (-1, 1):
        ctr = (128 + sx * 26, 92)
        arc = arc_pts(ctr, 80, -62, 62, 20) if sx > 0 else arc_pts(ctr, 80, 118, 242, 20)
        pts = [(128 + sx * 8, 46), (128 + sx * 30, 30)] + arc + [(128 + sx * 30, 154), (128 + sx * 8, 138)]
        blade = m_poly(pts)
        c.glow(blade, c.p["main"], 8, 0.5)
        c.shape(blade, col=mix(c.p["metal"], WHITE, 0.2), contrast=0.7)
        edge = m_and(blade, m_sub(m_ellipse(ctr, 80, 80), m_ellipse(ctr, 70, 70)))
        c.fill(edge, c.p["bright"], 0.95); c.glow(edge, c.p["main"], 5, 0.9)
    c.poly([(112, 24), (144, 24), (144, 160), (112, 160)], col=c.p["metal_dark"], contrast=0.6)
    c.poly([(120, 6), (136, 6), (140, 26), (116, 26)], col=c.p["bright"])
    c.circle((128, 92), 13, col=c.p["main"])
    c.sparkle((214, 36), 14); c.sparkle((44, 152), 10)

@recipe("Respawn")
def _(c):
    c.glow(m_arc((128, 108), 52, 180, 360, 20), c.p["main"], 8, 0.5)
    c.arc((128, 108), 52, 180, 360, 22, col=c.p["metal"], contrast=0.65)
    c.bar([(76, 108), (76, 128)], 22, col=c.p["metal"]); c.bar([(180, 108), (180, 128)], 22, col=c.p["metal"])
    c.poly([(48, 116), (208, 116), (208, 230), (48, 230)], col=c.p["gun"], contrast=0.55)
    c.fill(m_poly([(48, 116), (208, 116), (208, 132), (48, 132)]), WHITE, 0.12)
    c.circle((128, 168), 18, col=c.p["main"])
    c.fill(m_poly([(120, 172), (136, 172), (140, 208), (116, 208)]), c.p["deep"])
    # slash = no entry
    c.fill(m_line([(40, 60), (216, 236)], 22), INK, 0.85)
    c.beam([(40, 60), (216, 236)], 12, c.p["bright"], halo=1.8)

@recipe("Offguard")
def _(c):
    ctr = (128, 128)
    c.glow_circle(ctr, 90, c.p["main"], 20, 0.6)
    for a in range(0, 360, 60):
        arm = rot([(ctr[0], ctr[1]), (ctr[0], ctr[1] - 108)], a, ctr)
        c.bar(arm, 16, col=c.p["main"], contrast=0.5)
        p = lerp_pt(arm[0], arm[1], 0.62)
        for sgn in (-1, 1):
            q = rot([(p[0], p[1] - 34)], a + sgn * 55, p)[0]
            c.bar([p, q], 11, col=c.p["main"], contrast=0.5)
        c.circle(arm[1], 9, col=c.p["bright"])
    c.poly(star_pts(ctr, 40, 16, 6), col=c.p["core"], bevel=0)
    c.circle(ctr, 14, col=WHITE)

@recipe("LaserBeam")
def _(c):
    c.beam([(96, 128), (252, 128)], 34, halo=2.6)
    c.fill(m_line([(96, 128), (252, 128)], 8), WHITE)
    c.sparkle((236, 128), 30, thin=0.14)
    for (x, y) in ((150, 88), (196, 170)): c.sparkle((x, y), 8, glow=False)
    # heavy cannon emitter
    c.poly([(6, 66), (70, 66), (104, 92), (104, 164), (70, 190), (6, 190)], col=c.p["gun"], contrast=0.6)
    c.poly([(18, 42), (62, 42), (70, 66), (10, 66)], col=c.p["metal_dark"], contrast=0.6)
    c.poly([(18, 214), (62, 214), (70, 190), (10, 190)], col=c.p["metal_dark"], contrast=0.6)
    for x in (28, 52): c.fill(m_line([(x, 82), (x, 174)], 7), c.p["main"]); c.glow(m_line([(x, 82), (x, 174)], 7), c.p["main"], 3, 0.8)
    c.ring((104, 128), 32, 14, col=c.p["metal"], contrast=0.7)
    c.glow_circle((104, 128), 28, c.p["core"], 8, 1.0); c.fill(m_ellipse((104, 128), 24), c.p["core"])

@recipe("MindBlast")
def _(c):
    ctr = (128, 124)
    for r, a in ((110, 0.5), (140, 0.25)):
        c.fill(m_sub(m_ellipse(ctr, r), m_ellipse(ctr, r - 6)), c.p["main"], a)
    c.glow_circle(ctr, 70, c.p["main"], 16, 0.8)
    lobes = m_union(*[m_ellipse(p, r) for p, r in (((98, 108), 40), ((158, 108), 40), ((84, 140), 30), ((172, 140), 30),
                                                    ((110, 156), 30), ((146, 156), 30), ((128, 90), 34))])
    lobes = m_union(lobes, m_poly([(118, 166), (144, 166), (150, 200), (112, 200)]))
    c.shape(lobes, col=c.p["main"], contrast=0.55)
    c.fill(m_line([(128, 60), (128, 176)], 6), INK, 0.75)
    for pts in ([(74, 120), (96, 104), (106, 130), (118, 108)], [(182, 120), (160, 104), (150, 130), (138, 108)],
                [(90, 150), (108, 138), (120, 160)], [(166, 150), (148, 138), (136, 160)], [(112, 78), (128, 96), (144, 78)]):
        c.fill(m_line(pts, 6), INK, 0.7)
    c.bolt([(128, 176), (120, 196), (136, 200), (128, 226)], 8)
    for p in ((44, 60), (212, 60), (36, 170), (222, 170)): c.sparkle(p, 10)

@recipe("GrenadeLauncher")
def _(c):
    ctr = (120, 148)
    c.glow_circle(ctr, 66, c.p["main"], 12, 0.5)
    c.ellipse(ctr, 66, 74, col=c.p["gun"], contrast=0.6)
    # segmented pineapple grid
    for gy in (100, 134, 168, 202):
        c.fill(m_and(m_line([(40, gy), (200, gy)], 6), m_ellipse(ctr, 66, 74)), INK, 0.85)
    for gx in (76, 120, 164):
        c.fill(m_and(m_line([(gx, 60), (gx, 236)], 6), m_ellipse(ctr, 66, 74)), INK, 0.85)
    c.fill(m_sub(m_ellipse(ctr, 66, 74), m_ellipse(ctr, 60, 68)), c.p["main"], 0.6)
    c.poly([(100, 84), (140, 84), (140, 60), (100, 60)], col=c.p["metal_dark"])
    c.poly([(90, 60), (150, 60), (150, 44), (90, 44)], col=c.p["metal"], contrast=0.6)
    c.bar([(150, 50), (200, 40), (214, 90)], 10, col=c.p["metal"], contrast=0.6)
    c.ring((80, 44), 14, 6, col=c.p["main"])
    c.fill(m_ellipse((100, 116), 16, 10), WHITE, 0.25)
    c.sparkle((214, 150), 10); c.sparkle((30, 96), 8)

@recipe("Protected")
def _(c):
    sh = [(48, 40), (208, 40), (208, 130), (190, 180), (128, 232), (66, 180), (48, 130)]
    c.glow(m_poly(sh), c.p["main"], 12, 0.6)
    c.poly(sh, col=c.p["metal"], contrast=0.65)
    inner = [(64, 54), (192, 54), (192, 126), (176, 170), (128, 212), (80, 170), (64, 126)]
    c.fill(m_poly(inner), c.p["deep"], 0.9)
    # stone wall pattern
    for y in (72, 100, 128, 156, 184):
        c.fill(m_and(m_line([(64, y), (192, y)], 3), m_poly(inner)), INK, 0.6)
    for y0, off in ((54, 0), (72, 1), (100, 0), (128, 1), (156, 0), (184, 1)):
        for x in range(64 + (16 if off else 0), 192, 32):
            c.fill(m_and(m_line([(x, y0), (x, y0 + 28)], 3), m_poly(inner)), INK, 0.6)
    chev = [(76, 122), (128, 92), (180, 122), (180, 148), (128, 118), (76, 148)]
    c.poly(chev, col=c.p["main"], contrast=0.5)
    c.glow(m_poly(chev), c.p["main"], 6, 0.8)
    c.circle((128, 176), 14, col=c.p["bright"])

@recipe("Hypnosis")
def _(c):
    eye = m_and(m_ellipse((128, 128), 150, 150), m_and(m_ellipse((128, 40), 130, 150), m_ellipse((128, 216), 130, 150)))
    eye = m_and(m_ellipse((128, 40), 132, 152), m_ellipse((128, 216), 132, 152))
    c.glow(eye, c.p["main"], 12, 0.7)
    c.shape(eye, col=c.p["core"], contrast=0.35)
    c.circle((128, 128), 52, col=c.p["main"], contrast=0.5)
    pts = []
    for i in range(70):
        t = i / 69; a = math.radians(t * 900); r = 46 * (1 - t)
        pts.append((128 + r * math.cos(a), 128 + r * math.sin(a)))
    c.fill(m_poly(band(pts, 9, 3)), c.p["dark"], 0.95)
    c.fill(m_ellipse((128, 128), 10), INK)
    c.fill(m_ellipse((110, 108), 9), WHITE, 0.9)
    for a in (-150, -120, -90, -60, -30):
        p = rot([(128, 128 - 76), (128, 128 - 104)], a + 90, (128, 128))
        c.bar(p, 7, col=c.p["main"], contrast=0.5)
    for a in (-30, 0, 30):
        p = rot([(128, 128 + 76), (128, 128 + 100)], a, (128, 128))
        c.bar(p, 6, col=c.p["main"], contrast=0.5)

@recipe("Plague")
def _(c):
    def virus(ctr, r, n, seed):
        c.glow_circle(ctr, r * 1.3, c.p["main"], r * 0.3, 0.8)
        for i in range(n):
            a = math.radians(360 * i / n + seed * 17)
            tip = (ctr[0] + math.cos(a) * r * 1.45, ctr[1] + math.sin(a) * r * 1.45)
            c.bar([ctr, tip], r * 0.22, col=c.p["main"], contrast=0.5)
            c.circle(tip, r * 0.2, col=c.p["bright"])
        c.circle(ctr, r, col=c.p["main"], contrast=0.6)
        rng = random.Random(seed)
        for _ in range(4):
            px = ctr[0] + rng.uniform(-0.5, 0.5) * r; py = ctr[1] + rng.uniform(-0.5, 0.5) * r
            c.fill(m_ellipse((px, py), r * 0.16), c.p["dark"], 0.9)
    virus((204, 54), 24, 8, 2); virus((50, 206), 20, 7, 3); virus((118, 124), 50, 12, 1)

@recipe("Overclock")
def _(c):
    ctr = (128, 128)
    c.glow_circle(ctr, 80, c.p["main"], 16, 0.6)
    teeth = []
    for i in range(12):
        for j, rr in enumerate((104, 104, 86, 86)):
            a = math.radians(i * 30 + (-9, 9, 13, 17)[j])
            teeth.append((ctr[0] + rr * math.cos(a), ctr[1] + rr * math.sin(a)))
    gear = m_sub(m_poly(teeth), m_ellipse(ctr, 54))
    c.shape(gear, col=c.p["metal"], contrast=0.7)
    c.fill(m_sub(m_ellipse(ctr, 56), m_ellipse(ctr, 50)), c.p["main"], 0.8)
    c.fill(m_ellipse(ctr, 50), mix(c.p["dark"], BLACK, 0.5))
    c.glow_circle(ctr, 40, c.p["main"], 10, 1.0)
    pts = [(144, 78), (108, 132), (132, 132), (114, 180), (152, 120), (128, 120), (148, 78)]
    c.poly(pts, col=c.p["core"], contrast=0.4, outline=0.8)
    for a in range(0, 360, 90): c.fill(m_line(rot([(ctr[0] + 62, ctr[1]), (ctr[0] + 74, ctr[1])], a + 45, ctr), 4), c.p["bright"], 0.9)

@recipe("Executioner")
def _(c):
    for x in (36, 220): c.poly([(x - 10, 20), (x + 10, 20), (x + 10, 236), (x - 10, 236)], col=c.p["gun"], contrast=0.6)
    c.poly([(20, 10), (236, 10), (236, 32), (20, 32)], col=c.p["metal_dark"], contrast=0.6)
    c.poly([(14, 220), (242, 220), (242, 244), (14, 244)], col=c.p["metal_dark"], contrast=0.6)
    c.fill(m_poly([(46, 32), (210, 32), (210, 220), (46, 220)]), INK, 0.75)
    c.poly([(70, 232), (186, 232), (186, 206), (70, 206)], col=c.p["metal_dark"], contrast=0.6)
    c.fill(m_ellipse((128, 206), 26, 20), INK)
    c.fill(m_sub(m_ellipse((128, 206), 26, 20), m_ellipse((128, 204), 22, 16)), c.p["main"], 0.8)
    blade = [(48, 62), (208, 62), (208, 118), (48, 196)]
    c.glow(m_poly(blade), c.p["main"], 12, 0.9)
    c.poly(blade, col=mix(c.p["metal"], WHITE, 0.3), contrast=0.7)
    edge = m_sub(m_poly(blade), shift(m_poly(blade), 4, -8))
    c.fill(edge, c.p["bright"]); c.glow(edge, c.p["main"], 5, 1.0)
    c.poly([(48, 40), (208, 40), (208, 66), (48, 66)], col=c.p["main"], contrast=0.5)
    for x in (70, 128, 186): c.fill(m_ellipse((x, 53), 4), c.p["deep"])
    c.bar([(128, 34), (128, 12)], 7, col=c.p["main"])
    c.sparkle((60, 208), 10); c.sparkle((196, 130), 8)

# ---- GOD ----------------------------------------------------------------
@recipe("GalacticBeam")
def _(c):
    c.embers(10, (60, 20, 240, 200))
    c.glow(m_line([(60, 196), (236, 20)], 40), c.p["main"], 14, 0.8)
    hilt = (46, 210)
    tip = (238, 18)
    dx, dy = tip[0] - hilt[0], tip[1] - hilt[1]; L = math.hypot(dx, dy); ux, uy = dx / L, dy / L; nx, ny = -uy, ux
    g = (hilt[0] + ux * 30, hilt[1] + uy * 30)
    blade = [(g[0] + nx * 30, g[1] + ny * 30), (tip[0] - ux * 44 + nx * 26, tip[1] - uy * 44 + ny * 26), tip,
             (tip[0] - ux * 44 - nx * 26, tip[1] - uy * 44 - ny * 26), (g[0] - nx * 30, g[1] - ny * 30)]
    c.poly(blade, col=c.p["main"], contrast=0.45)
    c.fill(m_poly(band([lerp_pt(g, tip, 0.05), lerp_pt(g, tip, 0.9)], 20, 5)), c.p["core"], 0.95)
    c.fill(m_poly(band([lerp_pt(g, tip, 0.05), lerp_pt(g, tip, 0.85)], 8, 1)), WHITE)
    c.bar([(g[0] + nx * 30, g[1] + ny * 30), (g[0] - nx * 30, g[1] - ny * 30)], 12, col=c.p["gun"], contrast=0.6)
    c.bar([hilt, (g[0] - ux * 4, g[1] - uy * 4)], 13, col=c.p["gun"], contrast=0.6)
    c.circle((hilt[0] - ux * 3, hilt[1] - uy * 3), 9, col=c.p["main"])
    c.sparkle((tip[0] - 6, tip[1] + 6), 28, thin=0.14)
    c.sparkle((150, 60), 9, glow=False)

@recipe("SolarFlare")
def _(c):
    ctr = (128, 128)
    c.embers(8, (10, 10, 246, 246))
    c.glow_circle(ctr, 70, c.p["main"], 30, 0.7)
    for i in range(12):
        a = i * 30 + 15; l = 122 if i % 2 == 0 else 98
        pts = rot([(ctr[0], ctr[1] - l), (ctr[0] - 14, ctr[1] - 56), (ctr[0] + 14, ctr[1] - 56)], a, ctr)
        c.glow(m_poly(pts), c.p["main"], 5, 0.7)
        c.poly(pts, col=c.p["bright"] if i % 2 == 0 else c.p["main"], contrast=0.45)
    # prominence loop
    c.arc((186, 70), 46, 110, 340, 14, col=c.p["core"], contrast=0.3)
    c.glow(m_arc((186, 70), 46, 110, 340, 14), c.p["bright"], 6, 0.9)
    c.circle(ctr, 66, col=c.p["bright"], contrast=0.55)
    c.fill(m_ellipse(ctr, 50), mix(c.p["core"], WHITE, 0.3), 0.9)
    c.fill(m_ellipse((108, 108), 22, 16), WHITE, 0.7)
    for p, r in (((152, 112), 7), ((116, 152), 6), ((146, 150), 5)): c.fill(m_ellipse(p, r), c.p["main"], 0.5)

@recipe("CometStrike")
def _(c):
    head = (74, 182)
    c.embers(8, (100, 20, 240, 150))
    c.trail(head, (252, 4), 80, strength=1.0, soft=3)
    c.trail((head[0] - 6, head[1] + 4), (236, 24), 38, col=c.p["core"], strength=0.9, soft=2)
    for a in (110, 140, 200, 240):
        p = rot([(head[0] + 60, head[1]), (head[0] + 84, head[1])], a, head)
        c.fill(m_line(p, 5), c.p["bright"], 0.8)
    c.glow_circle(head, 52, c.p["main"], 14, 1.0)
    rock(c, head, 50, 7, col=c.p["deep"])
    c.fill(m_ellipse((head[0] - 14, head[1] - 14), 12), c.p["bright"], 0.6)
    c.fill(m_sub(m_ellipse(head, 52), m_ellipse((head[0] - 12, head[1] - 12), 52)), c.p["core"], 0.9)
    c.sparkle((174, 92), 12); c.sparkle((214, 44), 9)

@recipe("DeathVirus")
def _(c):
    c.embers(8, (16, 16, 240, 240), rmax=3)
    c.glow_circle((128, 120), 76, c.p["main"], 18, 0.9)
    skull(c, (128, 116), 74)
    for pts in ([(50, 190), (32, 214), (50, 214), (36, 244)], [(206, 190), (224, 214), (206, 214), (220, 244)]):
        c.bolt(pts, 7)
    c.sparkle((40, 60), 12); c.sparkle((216, 56), 10)

@recipe("VoidBurst")
def _(c):
    c.embers(6, (100, 10, 250, 120))
    ctr = (96, 160)
    # muzzle blast
    mz = (196, 60)
    c.glow_circle(mz, 44, c.p["main"], 16, 1.0)
    c.poly(star_pts(mz, 50, 22, 10), col=c.p["bright"], contrast=0.4, outline=0.9)
    c.fill(m_ellipse(mz, 16), WHITE)
    barrel = rot([(ctr[0] - 10, ctr[1] - 26), (ctr[0] + 110, ctr[1] - 26), (ctr[0] + 110, ctr[1] + 26), (ctr[0] - 10, ctr[1] + 26)], -45, ctr)
    c.poly(barrel, col=c.p["gun"], contrast=0.65)
    for t in (0.3, 0.55): c.poly(rot([(ctr[0] + 110 * t - 6, ctr[1] - 32), (ctr[0] + 110 * t + 6, ctr[1] - 32), (ctr[0] + 110 * t + 6, ctr[1] + 32), (ctr[0] + 110 * t - 6, ctr[1] + 32)], -45, ctr), col=c.p["metal_dark"], contrast=0.6)
    stripe = rot([(ctr[0], ctr[1] - 5), (ctr[0] + 100, ctr[1] - 5), (ctr[0] + 100, ctr[1] + 5), (ctr[0], ctr[1] + 5)], -45, ctr)
    c.fill(m_poly(stripe), c.p["main"]); c.glow(m_poly(stripe), c.p["main"], 4, 0.9)
    c.circle(ctr, 44, col=c.p["metal"], contrast=0.7)
    c.ring(ctr, 44, 8, col=c.p["metal_dark"])
    c.glow_circle(ctr, 24, c.p["main"], 8, 1.0); c.circle(ctr, 22, col=c.p["main"])
    c.fill(m_ellipse(ctr, 9), INK)
    c.poly([(40, 236), (152, 236), (136, 214), (56, 214)], col=c.p["metal_dark"], contrast=0.6)

@recipe("CelestialDisruption")
def _(c):
    ctr = (128, 128)
    c.embers(8, (16, 16, 240, 240))
    c.glow_circle(ctr, 90, c.p["main"], 18, 0.8)
    ring = m_sub(m_ellipse(ctr, 96), m_ellipse(ctr, 62))
    gap = m_poly([ctr, (ctr[0] + 140, ctr[1] - 90), (ctr[0] + 140, ctr[1] - 10)])
    gap2 = m_poly([ctr, (ctr[0] - 140, ctr[1] + 40), (ctr[0] - 140, ctr[1] + 100)])
    ring = m_sub(m_sub(ring, gap), gap2)
    c.shape(ring, col=c.p["main"], contrast=0.55)
    c.fill(m_and(ring, m_sub(m_ellipse(ctr, 82), m_ellipse(ctr, 76))), c.p["core"], 0.8)
    # fragments flying out of the gap
    for pts, sd in (([(200, 60), (222, 44), (234, 70), (214, 82)], 1), ([(236, 92), (250, 84), (252, 104), (240, 108)], 2),
                    ([(30, 178), (44, 166), (52, 186), (36, 194)], 3), ([(8, 150), (24, 148), (24, 166)], 4)):
        c.poly(pts, col=c.p["main"], contrast=0.55)
    # cracks
    for pts in ([(52, 62), (74, 86), (66, 104)], [(150, 214), (160, 190), (180, 196)]):
        c.fill(m_line(pts, 4), INK, 0.9)
    c.circle(ctr, 30, col=c.p["deep"], contrast=0.7)
    c.glow_circle(ctr, 20, c.p["main"], 10, 1.0); c.fill(m_ellipse(ctr, 14), c.p["core"])

@recipe("QuantumFlux")
def _(c):
    ctr = (128, 128)
    c.embers(10, (10, 10, 246, 246))
    c.glow_circle(ctr, 70, c.p["main"], 20, 0.8)
    for a in (0, 60, 120):
        m = m_sub(m_ellipse(ctr, 112, 44), m_ellipse(ctr, 100, 32))
        m = m.rotate(a, resample=Image.BICUBIC, center=(ctr[0] * S, ctr[1] * S))
        c.shape(m, col=c.p["main"], contrast=0.55, bevel=1.2)
    for a, t in ((0, 0.0), (60, 0.5), (120, 0.25), (180, 0.7)):
        px = ctr[0] + 106 * math.cos(math.radians(a + t * 60)); py = ctr[1] + 38 * math.sin(math.radians(a + t * 60))
        p = rot([(px, py)], a, ctr)[0]
        c.poly(star_pts(p, 16, 7, 6), col=c.p["core"], outline=0.8, bevel=0); c.glow_circle(p, 12, c.p["main"], 6, 1.0)
    c.circle(ctr, 34, col=c.p["bright"], contrast=0.5)
    c.fill(m_ellipse(ctr, 20), WHITE, 0.9)

@recipe("Supernova")
def _(c):
    ctr = (128, 128)
    c.embers(12, (6, 6, 250, 250))
    c.glow_circle(ctr, 80, c.p["main"], 30, 0.7)
    for a0 in (10, 100, 190, 280):
        seg = m_arc(ctr, 116, a0, a0 + 70, 9)
        c.glow(seg, c.p["main"], 6, 0.9); c.fill(seg, c.p["bright"], 0.9)
    c.poly(star_pts(ctr, 112, 40, 8, -90), col=c.p["main"], contrast=0.5)
    c.poly(star_pts(ctr, 80, 30, 8, -67.5), col=c.p["bright"], contrast=0.4, outline=0.8)
    c.poly(star_pts(ctr, 46, 22, 8, -90), col=c.p["core"], contrast=0.3, outline=0.6)
    c.circle(ctr, 22, col=WHITE, contrast=0.2, outline=0)

@recipe("DoomsdayClock")
def _(c):
    c.embers(6, (10, 10, 246, 246), rmax=2.5)
    c.glow_circle((128, 128), 70, c.p["main"], 16, 0.8)
    for y in (22, 234): c.poly([(58, y - 10), (198, y - 10), (198, y + 10), (58, y + 10)], col=c.p["gun"], contrast=0.6)
    for x in (66, 190): c.bar([(x, 32), (x, 224)], 10, col=c.p["metal_dark"])
    glass = m_poly([(72, 32), (184, 32), (184, 62), (136, 122), (136, 134), (184, 194), (184, 224), (72, 224), (72, 194), (120, 134), (120, 122), (72, 62)])
    c.fill(glass, mix(c.p["dark"], BLACK, 0.4), 0.85)
    c.fill(m_sub(glass, shift(glass, 3, 3)), c.p["bright"], 0.5)
    c.fill(m_sub(glass, shift(glass, -3, -3)), INK, 0.6)
    # sand
    c.fill(m_and(glass, m_poly([(72, 180), (184, 180), (184, 224), (72, 224)])), c.p["main"], 0.95)
    c.fill(m_and(glass, m_line([(128, 128), (128, 200)], 4)), c.p["main"])
    skull(c, (128, 78), 30, col=c.p["core"])
    c.fill(m_line([(128, 200), (128, 200)], 10), c.p["bright"])

@recipe("MeteorStorm")
def _(c):
    c.embers(8, (60, 10, 250, 200))
    mets = [((78, 186), 36, 11), ((176, 150), 28, 12), ((120, 84), 22, 13), ((208, 52), 15, 14)]
    for ctr, r, sd in mets:
        c.trail(ctr, (ctr[0] + r * 3.6, ctr[1] - r * 3.6), r * 1.8, strength=1.0)
    for ctr, r, sd in mets:
        c.trail(ctr, (ctr[0] + r * 2.2, ctr[1] - r * 2.2), r * 0.9, col=c.p["core"], soft=1.5)
        c.glow_circle(ctr, r * 1.2, c.p["main"], 8, 0.9)
        rock(c, ctr, r, sd, col=c.p["deep"])
        c.fill(m_sub(m_ellipse(ctr, r * 1.02), m_ellipse((ctr[0] + r * 0.25, ctr[1] - r * 0.25), r * 1.02)), c.p["bright"], 0.9)

# ---------------------------------------------------------------- driver
def render(w):
    c = Canvas(w["rarity"], sum(map(ord, w["id"])))
    R[w["id"]](c)
    return c.finish()

def sheet(icons):
    try: font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 13)
    except Exception: font = ImageFont.load_default()
    cols, cw, ch = 6, 172, 176
    groups = {}
    for w in DATA["weapons"]: groups.setdefault(w["rarity"], []).append(w)
    rows = sum(math.ceil(len(g) / cols) for g in groups.values())
    W, H = cols * cw + 24, rows * ch + 40 * len(groups) + 24
    im = Image.new("RGB", (W, H), PANEL); d = ImageDraw.Draw(im); y = 12
    for rar in ("common", "rare", "scarce", "god"):
        d.text((16, y + 10), rar.upper(), fill=hexrgb(DATA["rarityColors"][rar]), font=font); y += 40
        for i, w in enumerate(groups[rar]):
            x = 12 + (i % cols) * cw; yy = y + (i // cols) * ch
            ic = icons[w["id"]]
            im.paste(ic.resize((110, 110), Image.LANCZOS), (x + 8, yy), ic.resize((110, 110), Image.LANCZOS))
            im.paste(ic.resize((38, 38), Image.LANCZOS), (x + 126, yy + 36), ic.resize((38, 38), Image.LANCZOS))
            d.text((x + 8, yy + 118), w["name"], fill=(238, 242, 250), font=font)
        y += math.ceil(len(groups[rar]) / cols) * ch
    im.save(os.path.join(OUT, "sheet.png"))

def main(only=None):
    missing = [w["id"] for w in DATA["weapons"] if w["id"] not in R]
    assert not missing, f"no recipe for {missing}"
    os.makedirs(OUT, exist_ok=True)
    icons = {}
    for w in DATA["weapons"]:
        if only and w["id"] not in only: continue
        icons[w["id"]] = render(w)
        icons[w["id"]].save(os.path.join(OUT, w["id"] + ".png"))
        print("ok", w["id"])
    if not only: sheet(icons)

if __name__ == "__main__":
    main(set(sys.argv[1:]) or None)
