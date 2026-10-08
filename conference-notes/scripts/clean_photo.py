#!/usr/bin/env python3
"""Clean up a photo of a slide: rotate, straighten (perspective-correct) to the slide, enhance.

Usage:
  clean_photo.py IN OUT [--rotate DEG] [--corners "x,y x,y x,y x,y"] [--trim PX]

  --rotate   rotate counter-clockwise by DEG before anything else. Sideways photo whose slide
             top points LEFT (title reads bottom-to-top): -90. Top points RIGHT: 90. Upside down: 180.
             Corners refer to the rotated image.
  --corners  slide corners in order top-left, top-right, bottom-right, bottom-left (pixels, after
             rotation). Omit to skip perspective correction (enhance only).
  --trim     extra pixels to shave off every edge after warping (removes leftover dark borders).

Prints the size of IN (after rotation) so you can estimate corners, and the size of OUT.
Requires Pillow + numpy.
"""
import argparse
import numpy as np
from PIL import Image, ImageOps, ImageEnhance

ap = argparse.ArgumentParser()
ap.add_argument("inp"); ap.add_argument("out")
ap.add_argument("--rotate", type=float, default=0)
ap.add_argument("--corners")
ap.add_argument("--trim", type=int, default=0)
a = ap.parse_args()

im = ImageOps.exif_transpose(Image.open(a.inp)).convert("RGB")
if a.rotate:
    im = im.rotate(a.rotate, expand=True)
print("input size (after rotate):", im.size)

if a.corners:
    src = [tuple(map(float, p.split(","))) for p in a.corners.split()]
    assert len(src) == 4, "need 4 corners"
    (tl, tr, br, bl) = src
    W = int(max(np.hypot(tr[0]-tl[0], tr[1]-tl[1]), np.hypot(br[0]-bl[0], br[1]-bl[1])))
    H = int(max(np.hypot(bl[0]-tl[0], bl[1]-tl[1]), np.hypot(br[0]-tr[0], br[1]-tr[1])))
    dst = [(0, 0), (W, 0), (W, H), (0, H)]
    A, B = [], []
    for (x, y), (u, v) in zip(dst, src):
        A += [[x, y, 1, 0, 0, 0, -u*x, -u*y], [0, 0, 0, x, y, 1, -v*x, -v*y]]
        B += [u, v]
    c = np.linalg.solve(np.array(A, float), np.array(B, float))
    im = im.transform((W, H), Image.PERSPECTIVE, tuple(c), Image.BICUBIC)

if a.trim:
    t = a.trim
    im = im.crop((t, t, im.size[0]-t, im.size[1]-t))

im = ImageOps.autocontrast(im, cutoff=1)
im = ImageEnhance.Sharpness(im).enhance(1.5)
im.save(a.out)
print("output size:", im.size, "->", a.out)
