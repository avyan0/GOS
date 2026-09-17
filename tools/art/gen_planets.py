"""Procedural planet art for Gods of Space.

Writes assets/img/planets/<index>.png (512x512 RGBA, transparent bg) for every
planet in tools/art/data.json, plus sheet.png as a contact sheet. Deterministic.
"""
import json
import os

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'assets', 'img', 'planets')
SIZE = 512
SS = 2                     # supersample factor
N = SIZE * SS
LIGHT = np.array([-0.52, -0.48, 0.71])
LIGHT /= np.linalg.norm(LIGHT)
BG = (10, 14, 26)


# ---------------------------------------------------------------- noise
def _hash(ix, iy, iz, seed):
    h = (ix.astype(np.uint32) * np.uint32(374761393)
         + iy.astype(np.uint32) * np.uint32(668265263)
         + iz.astype(np.uint32) * np.uint32(2246822519)
         + np.uint32((seed * 1013904223) & 0xFFFFFFFF))
    h ^= h >> np.uint32(13)
    h *= np.uint32(1274126177)
    h ^= h >> np.uint32(16)
    return (h & np.uint32(0xFFFF)).astype(np.float32) / 65535.0


def vnoise(p, seed):
    """3D value noise, p: (...,3) float array -> values in [0,1]."""
    i = np.floor(p)
    f = p - i
    u = f * f * (3 - 2 * f)
    i = i.astype(np.int64)
    ix, iy, iz = i[..., 0], i[..., 1], i[..., 2]

    def c(dx, dy, dz):
        return _hash(ix + dx, iy + dy, iz + dz, seed)
    x00 = c(0, 0, 0) + (c(1, 0, 0) - c(0, 0, 0)) * u[..., 0]
    x10 = c(0, 1, 0) + (c(1, 1, 0) - c(0, 1, 0)) * u[..., 0]
    x01 = c(0, 0, 1) + (c(1, 0, 1) - c(0, 0, 1)) * u[..., 0]
    x11 = c(0, 1, 1) + (c(1, 1, 1) - c(0, 1, 1)) * u[..., 0]
    y0 = x00 + (x10 - x00) * u[..., 1]
    y1 = x01 + (x11 - x01) * u[..., 1]
    return y0 + (y1 - y0) * u[..., 2]


def fbm(p, seed, octaves=6, lac=2.0, gain=0.5, ridged=False):
    out = np.zeros(p.shape[:-1], np.float32)
    amp, freq, norm = 1.0, 1.0, 0.0
    for o in range(octaves):
        n = vnoise(p * freq, seed + o * 17)
        if ridged:
            n = 1.0 - abs(n * 2 - 1)
        out += amp * n
        norm += amp
        amp *= gain
        freq *= lac
    return out / norm


def warp(p, seed, strength, freq=1.0):
    d = np.stack([fbm(p * freq + off, seed + k * 101, octaves=4) - 0.5
                  for k, off in enumerate((0.0, 5.2, 9.7))], axis=-1)
    return p + d * strength


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0, 1)
    return t * t * (3 - 2 * t)


def lerp(a, b, t):
    return a + (np.asarray(b, np.float32) - a) * t[..., None]


def ramp(stops, t):
    """stops: list of (pos, (r,g,b)); t in [0,1] -> (...,3)."""
    t = np.clip(t, 0, 1)
    out = np.zeros(t.shape + (3,), np.float32)
    for (p0, c0), (p1, c1) in zip(stops[:-1], stops[1:]):
        m = (t >= p0) & (t <= p1)
        s = ((t - p0) / max(p1 - p0, 1e-6))[..., None]
        out = np.where(m[..., None], np.array(c0) + (np.array(c1) - np.array(c0)) * s, out)
    return out


def hsv(h, s, v):
    h = (h % 1.0) * 6
    i = int(h)
    f = h - i
    p, q, t = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
    return [(v, t, p), (q, v, p), (p, v, t), (p, q, v), (t, p, v), (v, p, q)][i]


# ---------------------------------------------------------------- geometry
def sphere_grid(radius_px):
    """Screen coords (units of planet radius), sphere normals, disc mask, depth."""
    c = (np.arange(N) + 0.5) / SS - SIZE / 2
    sx, sy = np.meshgrid(c / radius_px, c / radius_px)
    r2 = sx * sx + sy * sy
    disc = r2 <= 1
    z = np.sqrt(np.clip(1 - r2, 0, 1))
    normal = np.stack([sx, sy, z], -1)
    return sx, sy, np.sqrt(r2), disc, z, normal


def rot_y(v, a):
    c, s = np.cos(a), np.sin(a)
    x, y, z = v[..., 0], v[..., 1], v[..., 2]
    return np.stack([c * x + s * z, y, -s * x + c * z], -1)


def rot_z(v, a):
    c, s = np.cos(a), np.sin(a)
    x, y, z = v[..., 0], v[..., 1], v[..., 2]
    return np.stack([c * x - s * y, s * x + c * y, z], -1)


def shade(albedo, normal, z, spec_str=0.0, spec_pow=40.0, rim=(0.6, 0.7, 0.9), rim_str=0.35,
          terminator=0.12, ambient=0.05, emissive=None):
    ndl = np.einsum('...i,i->...', normal, LIGHT)
    diff = smoothstep(-terminator, terminator * 2.2, ndl) * np.clip(ndl, 0, 1) ** 0.55
    diff = np.clip(diff + smoothstep(-terminator, terminator, ndl) * 0.12, 0, 1)
    limb = 0.55 + 0.45 * np.clip(z, 0, 1) ** 0.5
    light = ambient + diff * limb
    col = albedo * light[..., None]
    # specular (Blinn-Phong, view = +z)
    h = LIGHT + np.array([0, 0, 1.0])
    h /= np.linalg.norm(h)
    ndh = np.clip(np.einsum('...i,i->...', normal, h), 0, 1)
    spec = (ndh ** spec_pow) * spec_str * smoothstep(0, 0.3, ndl)
    col += spec[..., None] * np.array([1.0, 0.98, 0.92])
    # rim light: bright edge on the lit half, fading around the limb
    rimf = (1 - np.clip(z, 0, 1)) ** 3.5 * rim_str * (0.35 + 0.65 * smoothstep(-0.6, 0.5, ndl))
    col += rimf[..., None] * np.array(rim)
    if emissive is not None:
        # glow reads strongest on the night side
        col += emissive * (0.55 + 0.45 * (1 - diff))[..., None]
    return col


def halo(r, sx, sy, r_max, color, width, strength, lit_bias=0.6, power=1.0, layers=()):
    """Atmosphere glow outside the disc: (...,3) premultiplied colour, alpha."""
    rgb, a = _halo(r, sx, sy, r_max, color, width, strength, lit_bias, power)
    for extra in layers:                                # outer layers composited underneath
        rgb, a = over(*_halo(r, sx, sy, r_max, **extra), rgb, a)
    return rgb, a


def _halo(r, sx, sy, r_max, color, width, strength, lit_bias=0.6, power=1.0):
    d = np.clip(r - 1, 0, None)
    a = np.exp(-d / width) ** power * strength
    dir_dot = (-sx * LIGHT[0] - sy * LIGHT[1]) / np.maximum(r, 1e-6)
    a = a * (1 - lit_bias + lit_bias * (0.5 + 0.5 * dir_dot))
    a = np.where(r > 1, a, 0) * (1 - smoothstep(r_max * 0.7, r_max, r))
    return np.array(color, np.float32)[None, None, :] * a[..., None], a


def over(dst_rgb, dst_a, src_rgb, src_a):
    """Straight-alpha 'over' composite. src_rgb premultiplied."""
    out_a = src_a + dst_a * (1 - src_a)
    out_rgb = src_rgb + dst_rgb * (1 - src_a)[..., None]
    return out_rgb, out_a


def rings(sx, sy, z_sphere, disc, tilt_deg, roll_deg, r_in, r_out, seed, palette, density=1.0,
          band_freq=14.0, glow=(1, 1, 1), glow_str=0.0):
    """Returns (front_rgb, front_a, back_rgb, back_a) premultiplied."""
    th = np.radians(roll_deg)
    inc = np.radians(tilt_deg)
    c, s = np.cos(th), np.sin(th)
    a = c * sx + s * sy
    b = (-s * sx + c * sy) / np.sin(inc)          # ring-plane coordinate along the tilt axis
    rho = np.sqrt(a * a + b * b)
    depth = b * np.cos(inc)                        # +z toward viewer, bottom half in front
    t = (rho - r_in) / (r_out - r_in)
    # banded density profile: 1D fbm along rho plus sharp gaps
    p = np.stack([t * band_freq, np.zeros_like(t) + 3.3, np.zeros_like(t) + 7.1], -1)
    band = fbm(p, seed, octaves=5, gain=0.55)
    gaps = 1.0
    for g, w in [(0.32, 0.03), (0.61, 0.05), (0.8, 0.02)]:
        gaps = gaps * (1 - 0.85 * np.exp(-((t - g) / w) ** 2))
    fine = 0.75 + 0.25 * np.sin(t * 160 + band * 9)
    dens = np.clip((band - 0.25) * 2.6, 0, 1) * gaps * fine * density
    edge = smoothstep(0, 0.03, t) * (1 - smoothstep(0.93, 1.0, t))
    alpha = np.clip(dens * edge, 0, 1)
    colour = ramp(palette, band)
    # planet shadow on the ring: shadow if the ray from P towards the light hits the sphere
    P = np.stack([sx, sy, depth], -1)
    t0 = -np.einsum('...i,i->...', P, LIGHT)
    closest = P + t0[..., None] * LIGHT[None, None, :]
    d2 = np.einsum('...i,...i->...', closest, closest)
    shadow = np.where(t0 > 0, 1 - smoothstep(0.85, 1.05, d2), 0.0)
    shadow = 1 - shadow * 0.92
    # lighting: unlit side of the tilted plane picks up a little scatter
    lit = 0.6 + 0.4 * abs(np.sin(inc) * LIGHT[2] + np.cos(inc) * (-s * LIGHT[0] + c * LIGHT[1]))
    rgb = colour * (lit * shadow)[..., None] + np.array(glow) * (alpha * glow_str * shadow)[..., None]
    rgb = rgb * alpha[..., None]
    front = (depth > z_sphere) | ~disc                 # bottom half passes in front of the planet
    front_a = np.where(front, alpha, 0)
    back_a = np.where(front | disc, 0, alpha)          # part hidden behind the planet is dropped
    return rgb * np.where(front, 1, 0)[..., None], front_a, rgb * np.where(front, 0, 1)[..., None], back_a


# ---------------------------------------------------------------- planet surfaces
def surf_verdanis(n, normal, seed):
    p = warp(n * 2.2, seed, 0.35)
    h = fbm(p * 1.6, seed + 1, octaves=7)
    h = (h - 0.5) * 2.6 + 0.46
    detail = fbm(n * 9, seed + 3, octaves=4, ridged=True)
    sea = h < 0.5
    ocean = ramp([(0, (0.01, 0.10, 0.22)), (0.45, (0.02, 0.28, 0.40)), (1, (0.10, 0.62, 0.62))],
                 smoothstep(0.15, 0.5, h))
    land = ramp([(0, (0.16, 0.42, 0.14)), (0.35, (0.10, 0.34, 0.11)), (0.6, (0.34, 0.36, 0.16)),
                 (0.82, (0.42, 0.35, 0.26)), (1, (0.92, 0.94, 0.96))],
                smoothstep(0.5, 0.86, h) * 0.85 + detail * 0.2)
    coast = smoothstep(0.47, 0.5, h)
    ocean = ocean * (1 - coast[..., None] * 0.15) + np.array((0.15, 0.65, 0.65)) * (coast * 0.25)[..., None]
    albedo = np.where(sea[..., None], ocean, land)
    # polar caps
    lat = abs(n[..., 1])
    cap = smoothstep(0.86, 0.95, lat + (h - 0.5) * 0.12)
    albedo = lerp(albedo, np.array((0.93, 0.95, 0.98)), cap)
    # cloud swirls
    cp = warp(n * np.array((1.4, 4.5, 1.4)) + 11.0, seed + 40, 0.9, freq=1.3)
    cl = fbm(cp * 1.8, seed + 41, octaves=6, gain=0.55)
    clouds = smoothstep(0.56, 0.78, cl) * 0.85
    albedo = lerp(albedo, np.array((0.97, 0.98, 1.0)), clouds)
    spec = np.where(sea, 0.9, 0.05) * (1 - clouds)
    return albedo, spec, None


def gas_bands(n, seed, palette, turbulence, band_freq, storm=None, normal=None):
    lat = n[..., 1]
    p = warp(n * 2.5, seed, turbulence, freq=1.0)
    p = warp(p, seed + 7, turbulence * 0.35, freq=3.5)
    v = lat + (p[..., 1] - n[..., 1]) * 0.9
    bands = 0.5 + 0.5 * np.sin(v * band_freq + 0.7 * np.sin(v * band_freq * 0.37 + 1.3))
    tex = fbm(p * 5, seed + 3, octaves=5)
    t = np.clip(bands * 0.75 + tex * 0.35 - 0.05, 0, 1)
    albedo = ramp(palette, t)
    if storm is not None:
        cx, cy, rx, ry = storm                       # screen-space ellipse on the visible face
        dx, dy = (normal[..., 0] - cx) / rx, (normal[..., 1] - cy) / ry
        d = np.sqrt(dx * dx + dy * dy)
        ang = np.arctan2(dy, dx)
        swirl = 0.5 + 0.5 * np.sin(ang * 2 - d * 7 + tex * 5)
        eye = smoothstep(1.0, 0.35, d)
        sc = ramp([(0, (0.62, 0.30, 0.10)), (0.5, (0.95, 0.80, 0.50)), (1, (0.85, 0.45, 0.15))], swirl)
        albedo = lerp(albedo, sc, eye * 0.9)
        albedo = albedo * (1 - 0.25 * np.exp(-((d - 1.05) / 0.12) ** 2))[..., None]   # dark collar
    return albedo


def surf_cyrene(n, normal, seed):
    pal = [(0, (0.35, 0.55, 0.78)), (0.3, (0.55, 0.78, 0.92)), (0.55, (0.86, 0.94, 0.98)),
           (0.75, (0.42, 0.66, 0.86)), (1, (0.22, 0.38, 0.62))]
    albedo = gas_bands(rot_z(n, -0.28), seed, pal, 0.34, 15)
    return albedo, 0.35, None


def surf_solhara(n, normal, seed):
    pal = [(0, (0.55, 0.32, 0.10)), (0.25, (0.85, 0.58, 0.22)), (0.5, (0.98, 0.85, 0.50)),
           (0.7, (0.78, 0.52, 0.18)), (0.85, (0.96, 0.78, 0.40)), (1, (0.45, 0.25, 0.08))]
    albedo = gas_bands(rot_z(n, 0.18), seed, pal, 0.45, 13, storm=(0.26, 0.30, 0.44, 0.20), normal=normal)
    return albedo, 0.25, None


def surf_ossara(n, normal, seed):
    p = warp(n * 1.6, seed, 0.3)
    h = fbm(p * 1.4, seed + 1, octaves=4, gain=0.45)
    lat = n[..., 1] + (h - 0.5) * 0.8
    dunes = 0.5 + 0.5 * np.sin(lat * 110 + fbm(n * 5, seed + 5, octaves=3) * 8)
    dunes = dunes ** 3 * smoothstep(0.42, 0.65, fbm(n * 2.2, seed + 6, octaves=3))
    base = ramp([(0, (0.45, 0.20, 0.06)), (0.4, (0.80, 0.42, 0.12)), (0.7, (0.95, 0.66, 0.30)),
                 (1, (0.99, 0.86, 0.58))], h * 1.1 + dunes * 0.22 - 0.15)
    # craters: bright rim towards the light, dark bowl and shadowed far rim
    rng = np.random.RandomState(seed + 99)
    tl = LIGHT - n * np.einsum('...i,i->...', n, LIGHT)[..., None]   # light in tangent plane
    shade_mul = np.ones(n.shape[:-1], np.float32)
    for _ in range(34):
        c = rng.normal(size=3)
        c /= np.linalg.norm(c)
        if c[2] < -0.2:
            continue
        rad = rng.uniform(0.04, 0.16)
        d = np.arccos(np.clip(np.einsum('...i,i->...', n, c), -1, 1)) / rad
        toward = np.einsum('...i,i->...', n - c, LIGHT)
        slope = np.clip(toward / (rad * 0.6), -1, 1)
        rim = np.exp(-((d - 1.0) / 0.12) ** 2)
        bowl = smoothstep(1.0, 0.5, d)
        shade_mul *= 1 + rim * (0.55 * slope + 0.15) - bowl * (0.35 - 0.35 * slope)
    albedo = base * np.clip(shade_mul, 0.3, 1.6)[..., None]
    return albedo, 0.12, None


def surf_nyx(n, normal, seed):
    p = warp(n * 2.4, seed, 0.5)
    rock = fbm(p * 2.5, seed + 1, octaves=6)
    albedo = ramp([(0, (0.02, 0.01, 0.05)), (0.5, (0.12, 0.06, 0.22)), (0.8, (0.28, 0.16, 0.42)),
                   (1, (0.40, 0.30, 0.55))], rock)
    cracks = fbm(warp(n * 3.0, seed + 8, 0.4) * 2.6, seed + 9, octaves=5, gain=0.55, ridged=True)
    crack = smoothstep(0.78, 0.94, cracks)
    heat = fbm(n * 3.5, seed + 20, octaves=3)
    glow_col = ramp([(0, (0.9, 0.15, 0.05)), (0.6, (1.0, 0.45, 0.10)), (1, (1.0, 0.85, 0.45))],
                    crack * 0.7 + heat * 0.4)
    emissive = glow_col * (crack * (0.5 + heat * 0.9))[..., None]
    # soft under-glow around the cracks
    emissive += np.array((0.6, 0.12, 0.05)) * (smoothstep(0.6, 0.9, cracks) * 0.35 * heat)[..., None]
    albedo = albedo * (1 - crack * 0.8)[..., None]
    return albedo, 0.18, emissive


def surf_hevalten(n, normal, seed):
    p = warp(n * 2.2, seed, 0.45)
    rock = fbm(p * 2.8, seed + 1, octaves=6)
    albedo = ramp([(0, (0.08, 0.01, 0.02)), (0.45, (0.34, 0.04, 0.04)), (0.75, (0.62, 0.10, 0.07)),
                   (1, (0.85, 0.25, 0.12))], rock)
    cracks = fbm(warp(n * 2.0, seed + 8, 0.45) * 2.2, seed + 9, octaves=4, gain=0.45, ridged=True)
    dark = smoothstep(0.76, 0.9, cracks)
    albedo = albedo * (1 - dark * 0.92)[..., None]
    ember = fbm(n * 7, seed + 30, octaves=4, ridged=True)
    ember = smoothstep(0.86, 0.99, ember) * smoothstep(0.55, 0.8, cracks)
    emissive = ramp([(0, (1.0, 0.25, 0.05)), (1, (1.0, 0.8, 0.3))], ember) * (ember * 1.4)[..., None]
    emissive += np.array((0.9, 0.15, 0.05)) * (dark * 0.25 * fbm(n * 4, seed + 31, octaves=3))[..., None]
    return albedo, 0.15, emissive


# ---------------------------------------------------------------- planets
PLANET_STYLE = {
    'Verdanis': dict(surf=surf_verdanis, radius=192, spin=(0.9, 0.15),
                     halo=dict(color=(0.35, 0.75, 1.0), width=0.10, strength=0.75), rim=(0.55, 0.85, 1.0),
                     rim_str=0.55, spec_pow=60),
    'Cyrene': dict(surf=surf_cyrene, radius=128, spin=(0.3, 0.0),
                   halo=dict(color=(0.55, 0.85, 1.0), width=0.09, strength=0.6), rim=(0.7, 0.9, 1.0),
                   rim_str=0.45, spec_pow=30,
                   rings=dict(tilt_deg=22, roll_deg=-16, r_in=1.45, r_out=2.05, band_freq=10, density=0.85,
                              palette=[(0, (0.55, 0.75, 0.95)), (0.5, (0.85, 0.95, 1.0)), (1, (0.65, 0.85, 1.0))],
                              glow=(0.6, 0.9, 1.0), glow_str=0.25)),
    'Ossara': dict(surf=surf_ossara, radius=192, spin=(2.1, 0.35),
                   halo=dict(color=(1.0, 0.65, 0.3), width=0.07, strength=0.5), rim=(1.0, 0.8, 0.5),
                   rim_str=0.4, spec_pow=25),
    'Nyx': dict(surf=surf_nyx, radius=192, spin=(4.0, -0.2),
                halo=dict(color=(0.7, 0.3, 1.0), width=0.11, strength=0.6, lit_bias=0.3), rim=(0.8, 0.5, 1.0),
                rim_str=0.5, spec_pow=35, ambient=0.03),
    'Solhara': dict(surf=surf_solhara, radius=126, spin=(1.2, 0.1),
                    halo=dict(color=(1.0, 0.8, 0.4), width=0.09, strength=0.65), rim=(1.0, 0.9, 0.6),
                    rim_str=0.45, spec_pow=30,
                    rings=dict(tilt_deg=24, roll_deg=12, r_in=1.35, r_out=2.15, band_freq=16, density=1.0,
                               palette=[(0, (0.55, 0.38, 0.18)), (0.4, (0.85, 0.68, 0.40)), (0.7, (0.98, 0.9, 0.7)),
                                        (1, (0.7, 0.5, 0.25))])),
    'Hevalten': dict(surf=surf_hevalten, radius=188, spin=(5.3, 0.25),
                     halo=dict(color=(0.75, 0.08, 0.03), width=0.07, strength=0.85, lit_bias=0.3,
                               layers=[dict(color=(0.06, 0.0, 0.01), width=0.3, strength=0.8, lit_bias=0.0, power=0.7)]),
                     rim=(1.0, 0.35, 0.2), rim_str=0.6, spec_pow=30, ambient=0.04),
}


def render_planet(planet):
    name, hue = planet['name'], planet['hue']
    st = PLANET_STYLE[name]
    seed = 1000 + planet['index'] * 37
    radius = st['radius']
    sx, sy, r, disc, z, normal = sphere_grid(radius)
    n = rot_y(rot_z(normal, st['spin'][1]), st['spin'][0])   # surface sample coords

    # surface (only evaluated inside the disc to save time)
    idx = np.where(disc)
    nd = n[idx]
    albedo_d, spec_d, emis_d = st['surf'](nd, normal[idx], seed)
    albedo = np.zeros(disc.shape + (3,), np.float32)
    albedo[idx] = albedo_d
    spec = np.zeros(disc.shape, np.float32)
    spec[idx] = spec_d
    emissive = None
    if emis_d is not None:
        emissive = np.zeros(disc.shape + (3,), np.float32)
        emissive[idx] = emis_d

    rgb = shade(albedo, normal, z, spec_str=spec, spec_pow=st['spec_pow'], rim=st['rim'],
                rim_str=st['rim_str'], ambient=st.get('ambient', 0.05), emissive=emissive)
    # anti-aliased disc edge
    edge = 1 - smoothstep(1 - 1.0 / radius, 1 + 0.5 / radius, r)
    disc_a = edge
    disc_rgb = np.clip(rgb, 0, 1) * disc_a[..., None]

    # composite: halo -> back rings -> planet -> front rings
    out_rgb = np.zeros(disc.shape + (3,), np.float32)
    out_a = np.zeros(disc.shape, np.float32)
    h_rgb, h_a = halo(r, sx, sy, SIZE / 2 / radius, **st['halo'])
    out_rgb, out_a = over(out_rgb, out_a, h_rgb, h_a)
    if 'rings' in st:
        f_rgb, f_a, b_rgb, b_a = rings(sx, sy, z, r <= 1, seed=seed + 5, **st['rings'])
        out_rgb, out_a = over(out_rgb, out_a, b_rgb, b_a)
    out_rgb, out_a = over(out_rgb, out_a, disc_rgb, disc_a)
    if 'rings' in st:
        out_rgb, out_a = over(out_rgb, out_a, f_rgb, f_a)

    # un-premultiply, downsample
    out_a = np.clip(out_a, 0, 1)
    straight = np.where(out_a[..., None] > 1e-4, out_rgb / np.maximum(out_a, 1e-4)[..., None], 0)
    img = np.concatenate([np.clip(straight, 0, 1), out_a[..., None]], -1)
    img = img.reshape(SIZE, SS, SIZE, SS, 4).mean(axis=(1, 3))
    # premultiplied average is more correct at edges; approximate by weighting rgb by alpha
    pm = (np.clip(out_rgb, 0, 1)).reshape(SIZE, SS, SIZE, SS, 3).mean(axis=(1, 3))
    a = img[..., 3]
    img[..., :3] = np.where(a[..., None] > 1e-4, pm / np.maximum(a, 1e-4)[..., None], 0)
    return Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8), 'RGBA')


def main():
    with open(os.path.join(ROOT, 'tools', 'art', 'data.json')) as f:
        planets = json.load(f)['planets']
    os.makedirs(OUT, exist_ok=True)
    imgs = []
    for p in planets:
        img = render_planet(p)
        path = os.path.join(OUT, '%d.png' % p['index'])
        img.save(path)
        print('wrote', path)
        imgs.append((p['name'], img))

    cell = 300
    sheet = Image.new('RGBA', (cell * 3, cell * 2 + 30), BG + (255,))
    draw = ImageDraw.Draw(sheet)
    for i, (name, img) in enumerate(imgs):
        x, y = (i % 3) * cell, (i // 3) * cell
        thumb = img.resize((256, 256), Image.LANCZOS)
        sheet.alpha_composite(thumb, (x + 22, y + 10))
        small = img.resize((70, 70), Image.LANCZOS)
        sheet.alpha_composite(small, (x + cell - 80, y + cell - 60))
        draw.text((x + 22, y + cell - 24), name, fill=(238, 242, 250, 255))
    sheet.save(os.path.join(OUT, 'sheet.png'))
    print('wrote sheet.png')


if __name__ == '__main__':
    main()
