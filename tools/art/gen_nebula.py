"""Pixel-art nebula backdrop: 320x180, drawn at 4x with nearest filtering.

python tools/art/gen_nebula.py  ->  assets/img/nebula.png
Fractal noise, domain-warped, shaded with an ordered (Bayer) dither into a few
colours from the same Endesga 32 palette the sprites use.
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
W, H = 320, 180
rng = np.random.default_rng(11)


def value_noise(w, h, cell):
    gw, gh = w // cell + 2, h // cell + 2
    grid = rng.random((gh, gw))
    y, x = np.mgrid[0:h, 0:w] / cell
    x0, y0 = x.astype(int), y.astype(int)
    fx, fy = x - x0, y - y0
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = grid[y0, x0], grid[y0, x0 + 1]
    c, d = grid[y0 + 1, x0], grid[y0 + 1, x0 + 1]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def fbm(w, h, base, octaves=5):
    out, amp, tot = np.zeros((h, w)), 1.0, 0.0
    for o in range(octaves):
        out += value_noise(w, h, max(2, base >> o)) * amp
        tot += amp
        amp *= 0.5
    return out / tot


def hexrgb(h): return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.float32)


# background -> faint gas -> bright gas, two hue families
BG = hexrgb('0a0e1a')
RAMP_A = [hexrgb(h) for h in ('0f1526', '181425', '262b44', '3a4466', '124e89')]
RAMP_B = [hexrgb(h) for h in ('0f1526', '181425', '3e2731', '68386c', 'b55088')]
BAYER = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0


def main():
    density = fbm(W, H, 64)
    warp = fbm(W, H, 32)
    density = fbm(W, H, 48) * 0.6 + density * 0.4
    density = np.clip((density - 0.42) * 2.6 + (warp - 0.5) * 0.4, 0, 1)
    # keep the centre of the screen darker so UI text reads
    y, x = np.mgrid[0:H, 0:W]
    vign = 1 - 0.55 * np.exp(-(((x - W / 2) / (W * 0.32)) ** 2 + ((y - H / 2) / (H * 0.36)) ** 2))
    density *= vign
    hue = fbm(W, H, 96, 3)  # which colour family
    levels = len(RAMP_A) - 1
    dither = np.tile(BAYER, (H // 4 + 1, W // 4 + 1))[:H, :W]
    idx = np.clip(np.floor(density * levels + dither), 0, levels).astype(int)
    img = np.zeros((H, W, 3), np.float32)
    for k in range(levels + 1):
        m = idx == k
        mix = (hue > 0.5)[m]
        img[m] = np.where(mix[:, None], RAMP_B[k], RAMP_A[k])
    img[idx == 0] = BG
    Image.fromarray(img.astype(np.uint8), 'RGB').save(os.path.join(ROOT, 'assets', 'img', 'nebula.png'))
    print('wrote assets/img/nebula.png')


if __name__ == '__main__':
    main()
