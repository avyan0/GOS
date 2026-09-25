"""Turn the high-res generated art into hand-made-looking pixel art.

The generators (gen_aliens.py, gen_weapons.py, gen_planets.py) render smooth 256-512px
images; on their own they have the glossy, over-lit look of AI art. This pass:
  1. drops soft glows (low-alpha pixels),
  2. area-downsamples to a small native size,
  3. snaps every colour to one shared 32-colour palette (Endesga 32) so the whole game
     reads as one hand-picked set,
  4. cleans stray single pixels and adds a 1px dark outline.
The game draws these with nearest-neighbour filtering at integer scales.

Usage: python tools/art/pixelize.py            (writes assets/img/{aliens,weapons,planets})
       python tools/art/pixelize.py --preview  (writes a comparison sheet to tools/art/sheets)
Sources are read from tools/art/src/{aliens,weapons,planets} (the generators' output).
"""
import os, sys, glob
import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SRC = os.path.join(ROOT, 'tools', 'art', 'src')
OUT = os.path.join(ROOT, 'assets', 'img')

ENDESGA32 = ['be4a2f', 'd77643', 'ead4aa', 'e4a672', 'b86f50', '733e39', '3e2731', 'a22633',
             'e43b44', 'f77622', 'feae34', 'fee761', '63c74d', '3e8948', '265c42', '193c3e',
             '124e89', '0099db', '2ce8f5', 'ffffff', 'c0cbdc', '8b9bb4', '5a6988', '3a4466',
             '262b44', '181425', 'ff0044', '68386c', 'b55088', 'f6757a', 'e8b796', 'c28569']
PAL = np.array([[int(h[i:i + 2], 16) for i in (0, 2, 4)] for h in ENDESGA32], dtype=np.float32)
OUTLINE = np.array([24, 20, 37], dtype=np.uint8)  # 181425

# native pixel size per kind, and how much glow to cut (alpha threshold on the source)
KINDS = {
    'aliens':  dict(size=28, cut=0.55, outline=True, crop=True),
    'weapons': dict(size=28, cut=0.60, outline=True, crop=True),
    'planets': dict(size=80, cut=0.30, outline=False, crop=False),
}


def to_linear(c): return c ** 2.2  # c in 0..1
def to_srgb(c): return np.clip(c, 0, 1) ** (1 / 2.2) * 255


def quantize(rgb):
    """Nearest palette colour in a perceptual-ish space (weighted RGB)."""
    w = np.array([0.30, 0.59, 0.11]) * 3
    d = (((rgb[..., None, :] - PAL[None, None, :, :]) ** 2) * w).sum(-1)
    return PAL[d.argmin(-1)].astype(np.uint8)


def downsample(img, size, cut, crop=True):
    from PIL import ImageFilter
    img = img.convert('RGBA')
    # sharpen first so small features (eyes, rims) survive the shrink
    rgb = img.convert('RGB').filter(ImageFilter.UnsharpMask(radius=img.width / 64, percent=130, threshold=4))
    img = Image.merge('RGBA', (*rgb.split(), img.split()[3]))
    a = np.asarray(img, dtype=np.float32) / 255.0
    alpha = a[..., 3]
    alpha = np.where(alpha < cut, 0.0, alpha)  # kill the soft glow halo
    # crop to content so every sprite fills its cell the same way
    ys, xs = np.nonzero(alpha > 0)
    if len(xs) == 0:
        return np.zeros((size, size, 4), np.uint8)
    x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    side = max(x1 - x0, y1 - y0)
    cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
    pad = int(side * 0.04)
    half = side // 2 + pad
    box = (cx - half, cy - half, cx + half, cy + half) if crop else (0, 0, a.shape[1], a.shape[0])
    rgb = to_linear(a[..., :3]) * alpha[..., None]           # premultiplied, linear light
    stack = np.dstack([rgb, alpha])
    # resample each channel with a box filter
    chans = []
    for k in range(4):
        ch = Image.fromarray((stack[..., k] * 255).astype(np.float32), 'F')
        ch = ch.crop(box).resize((size - 2, size - 2), Image.BOX)
        chans.append(np.asarray(ch) / 255.0)
    rgb_s = np.dstack(chans[:3])
    al = chans[3]
    with np.errstate(invalid='ignore', divide='ignore'):
        rgb_s = np.where(al[..., None] > 1e-4, rgb_s / al[..., None], 0)
    rgb_s = to_srgb(rgb_s)
    # a touch more contrast/saturation so the palette snap keeps the shapes readable
    lum = rgb_s.mean(-1, keepdims=True)
    rgb_s = np.clip(lum + (rgb_s - lum) * 1.15, 0, 255)
    out = np.zeros((size, size, 4), np.uint8)
    out[1:-1, 1:-1, :3] = quantize(rgb_s)
    out[1:-1, 1:-1, 3] = np.where(al > (0.3 if not crop else 0.5), 255, 0)
    return out


def clean(px):
    """Remove isolated opaque pixels and fill single-pixel holes."""
    a = px[..., 3] > 0
    n = sum(np.roll(np.roll(a, dy, 0), dx, 1) for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)))
    px[(a) & (n == 0), 3] = 0
    hole = (~a) & (n == 4)
    for y, x in zip(*np.nonzero(hole)):
        px[y, x] = px[y - 1, x]
    return px


def outline(px):
    a = px[..., 3] > 0
    ring = np.zeros_like(a)
    for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
        ring |= np.roll(np.roll(a, dy, 0), dx, 1)
    ring &= ~a
    px[ring, :3] = OUTLINE
    px[ring, 3] = 255
    return px


def process(kind, path):
    cfg = KINDS[kind]
    px = downsample(Image.open(path), cfg['size'], cfg['cut'], cfg['crop'])
    px = clean(px)
    if cfg['outline']:
        px = outline(px)
    return Image.fromarray(px, 'RGBA')


def sources(kind):
    return sorted(p for p in glob.glob(os.path.join(SRC, kind, '*.png')) if not p.endswith('sheet.png'))


def preview():
    names = {'aliens': ['King', 'Medic', 'VoidTitan', 'Joe', 'Giant', 'Necromancer', 'Swarmling', 'Albot'],
             'weapons': ['CosmicFire', 'ChainLightning', 'Plague', 'GalacticBeam', 'Barricade', 'DoomsdayClock', 'MeteorStorm', 'AstroidRain'],
             'planets': ['1', '2', '3', '4', '5', '6']}
    cell = 200
    sheet = Image.new('RGBA', (cell * 8, cell * 3), (10, 14, 26, 255))
    for r, kind in enumerate(['aliens', 'weapons', 'planets']):
        for c, n in enumerate(names[kind]):
            im = process(kind, os.path.join(SRC, kind, n + '.png'))
            sc = (cell - 20) // im.width
            big = im.resize((im.width * sc, im.height * sc), Image.NEAREST)
            sheet.alpha_composite(big, (c * cell + (cell - big.width) // 2, r * cell + (cell - big.height) // 2))
    os.makedirs(os.path.join(ROOT, 'tools', 'art', 'sheets'), exist_ok=True)
    out = os.path.join(ROOT, 'tools', 'art', 'sheets', 'pixel_preview.png')
    sheet.save(out)
    print(out)


def main():
    if '--preview' in sys.argv:
        return preview()
    for kind in KINDS:
        os.makedirs(os.path.join(OUT, kind), exist_ok=True)
        files = sources(kind)
        for p in files:
            process(kind, p).save(os.path.join(OUT, kind, os.path.basename(p)))
        print(kind, len(files))


if __name__ == '__main__':
    main()
