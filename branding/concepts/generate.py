#!/usr/bin/env python3
"""
Abstract, name-free shape concepts for the os-eco root logo.
All marks are minimal — 1-2 tones, single iconic shape, no text, no tool refs.
Designed to outlive the current project lineup.
"""

import math
import os
from PIL import Image, ImageDraw

OUT = os.path.dirname(os.path.abspath(__file__))
SCALE = 4
SIZE = 256
BG = (22, 27, 34)
INK = (220, 224, 230)
ACCENT = (255, 183, 77)
DIM = (110, 120, 130)
EARTH = (180, 145, 100)


def canvas():
    sw = SIZE * SCALE
    img = Image.new("RGB", (sw, sw), BG)
    return img, ImageDraw.Draw(img), sw


def save(img, name):
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    img.save(os.path.join(OUT, name))
    print(f"  {name}")


# A — concentric contour rings (topographic / "ecosystem layers")
def concept_a():
    img, d, sw = canvas()
    cx, cy = sw // 2, sw // 2
    rings = 5
    base_r = int(sw * 0.42)
    step = base_r // rings
    stroke = int(sw * 0.018)
    for i in range(rings):
        r = base_r - i * step
        color = INK if i == 0 else DIM
        d.ellipse([cx - r, cy - r, cx + r, cy + r],
                  outline=color, width=stroke)
    # Single accent dot at center
    dot_r = int(sw * 0.04)
    d.ellipse([cx - dot_r, cy - dot_r, cx + dot_r, cy + dot_r], fill=ACCENT)
    save(img, "root-A-contour-rings.png")


# B — three stacked bars, descending width (minimal layered system)
def concept_b():
    img, d, sw = canvas()
    bar_h = int(sw * 0.10)
    gap = int(sw * 0.06)
    widths = [0.58, 0.42, 0.26]
    cx, cy = sw // 2, sw // 2
    total_h = 3 * bar_h + 2 * gap
    y = cy - total_h // 2
    radius = bar_h // 2
    for w_frac in widths:
        w_px = int(sw * w_frac)
        d.rounded_rectangle(
            [cx - w_px // 2, y, cx + w_px // 2, y + bar_h],
            radius=radius, fill=INK,
        )
        y += bar_h + gap
    save(img, "root-B-three-bars.png")


# C — single hexagonal cell with notched gap (modular ecosystem)
def concept_c():
    img, d, sw = canvas()
    cx, cy = sw // 2, sw // 2
    r = int(sw * 0.36)
    stroke = int(sw * 0.04)
    # Outer hex
    pts = []
    for i in range(6):
        a = -math.pi / 2 + i * math.pi / 3
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    d.line(pts + [pts[0]], fill=INK, width=stroke, joint="curve")
    # Inner smaller hex, rotated 30deg, dim
    r2 = int(sw * 0.18)
    pts2 = []
    for i in range(6):
        a = i * math.pi / 3
        pts2.append((cx + r2 * math.cos(a), cy + r2 * math.sin(a)))
    d.line(pts2 + [pts2[0]], fill=DIM, width=stroke // 2, joint="curve")
    save(img, "root-C-nested-hex.png")


# D — single curved arc + dot ("growth" minimal)
def concept_d():
    img, d, sw = canvas()
    cx, cy = sw // 2, sw // 2
    # Quarter arc bottom-right of center, suggesting a sprout/sweep
    r = int(sw * 0.36)
    stroke = int(sw * 0.05)
    bbox = [cx - r, cy - r, cx + r, cy + r]
    # Draw arc from 180deg to 270deg (upper-left quadrant of circle)
    d.arc(bbox, start=180, end=270, fill=INK, width=stroke)
    # Anchor dot at arc start (left side)
    dot_r = int(sw * 0.05)
    d.ellipse([cx - r - dot_r, cy - dot_r, cx - r + dot_r, cy + dot_r], fill=INK)
    # Accent dot at arc end (top)
    d.ellipse([cx - dot_r, cy - r - dot_r, cx + dot_r, cy - r + dot_r], fill=ACCENT)
    save(img, "root-D-arc-sprout.png")


# E — three offset overlapping circles (overlapping systems)
def concept_e():
    img, d, sw = canvas()
    cx, cy = sw // 2, sw // 2
    r = int(sw * 0.22)
    stroke = int(sw * 0.035)
    # Triangle arrangement
    offset = int(sw * 0.13)
    positions = [
        (cx, cy - offset),
        (cx - int(offset * 0.85), cy + int(offset * 0.5)),
        (cx + int(offset * 0.85), cy + int(offset * 0.5)),
    ]
    colors = [INK, INK, INK]
    for (x, y), c in zip(positions, colors):
        d.ellipse([x - r, y - r, x + r, y + r], outline=c, width=stroke)
    save(img, "root-E-trefoil.png")


# F — grid of dots, one accent ("nodes in a system")
def concept_f():
    img, d, sw = canvas()
    n = 5
    margin = int(sw * 0.22)
    span = sw - 2 * margin
    step = span // (n - 1)
    dot_r = int(sw * 0.025)
    accent_r = int(sw * 0.045)
    cx, cy = sw // 2, sw // 2
    for i in range(n):
        for j in range(n):
            x = margin + j * step
            y = margin + i * step
            if i == n // 2 and j == n // 2:
                d.ellipse([x - accent_r, y - accent_r,
                           x + accent_r, y + accent_r], fill=ACCENT)
            else:
                d.ellipse([x - dot_r, y - dot_r,
                           x + dot_r, y + dot_r], fill=INK)
    save(img, "root-F-grid.png")


if __name__ == "__main__":
    print("Generating os-eco abstract root concepts:")
    concept_a()
    concept_b()
    concept_c()
    concept_d()
    concept_e()
    concept_f()
