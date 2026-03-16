import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

// ── Color helper ───────────────────────────────────────────────────────
img.ColorRgba8 rgba(int r, int g, int b, [int a = 255]) =>
    img.ColorRgba8(r, g, b, a);

/// Lighten a color by [amount] (0-100).
img.ColorRgba8 lighten(img.ColorRgba8 c, int amount) {
  final f = amount / 100;
  return rgba(
    (c.r + (255 - c.r.toInt()) * f).round().clamp(0, 255),
    (c.g + (255 - c.g.toInt()) * f).round().clamp(0, 255),
    (c.b + (255 - c.b.toInt()) * f).round().clamp(0, 255),
    c.a.toInt(),
  );
}

/// Darken a color by [amount] (0-100).
img.ColorRgba8 darken(img.ColorRgba8 c, int amount) {
  final f = 1 - amount / 100;
  return rgba(
    (c.r.toInt() * f).round().clamp(0, 255),
    (c.g.toInt() * f).round().clamp(0, 255),
    (c.b.toInt() * f).round().clamp(0, 255),
    c.a.toInt(),
  );
}

/// Blend color with alpha onto existing pixel (simple alpha blend).
void blendPixel(img.Image image, int x, int y, img.ColorRgba8 color) {
  if (x < 0 || x >= image.width || y < 0 || y >= image.height) return;
  final a = color.a.toInt() / 255.0;
  if (a <= 0) return;
  final existing = image.getPixel(x, y);
  final er = existing.r.toInt();
  final eg = existing.g.toInt();
  final eb = existing.b.toInt();
  final ea = existing.a.toInt();
  final cr = color.r.toInt();
  final cg = color.g.toInt();
  final cb = color.b.toInt();
  final nr = (cr * a + er * (1 - a)).round().clamp(0, 255);
  final ng = (cg * a + eg * (1 - a)).round().clamp(0, 255);
  final nb = (cb * a + eb * (1 - a)).round().clamp(0, 255);
  final na = max(ea, color.a.toInt());
  image.setPixelRgba(x, y, nr, ng, nb, na);
}

// ── Drawing primitives ─────────────────────────────────────────────────

void setPixel(img.Image image, int x, int y, img.ColorRgba8 color) {
  if (x < 0 || x >= image.width || y < 0 || y >= image.height) return;
  image.setPixelRgba(
      x, y, color.r.toInt(), color.g.toInt(), color.b.toInt(), color.a.toInt());
}

void fillEllipse(img.Image image, int cx, int cy, int rx, int ry,
    img.ColorRgba8 color) {
  if (rx <= 0 || ry <= 0) return;
  for (int y = cy - ry; y <= cy + ry; y++) {
    for (int x = cx - rx; x <= cx + rx; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      if (dx * dx + dy * dy <= 1.0) {
        setPixel(image, x, y, color);
      }
    }
  }
}

void fillCircle(
    img.Image image, int cx, int cy, int r, img.ColorRgba8 color) {
  fillEllipse(image, cx, cy, r, r, color);
}

/// Filled ellipse with 4-tone shading (highlight, base, shadow, deep shadow).
/// Light comes from upper-left.
void fillShadedEllipse(img.Image image, int cx, int cy, int rx, int ry,
    img.ColorRgba8 base) {
  final highlight = lighten(base, 25);
  final shadow = darken(base, 20);
  final deep = darken(base, 40);

  if (rx <= 0 || ry <= 0) return;
  for (int y = cy - ry; y <= cy + ry; y++) {
    for (int x = cx - rx; x <= cx + rx; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      final dist = dx * dx + dy * dy;
      if (dist <= 1.0) {
        // Shading based on position relative to center
        // Light from upper-left: negative dx and negative dy = highlight
        final shade = dx * 0.5 + dy * 0.5; // -1 = highlight, +1 = deep shadow
        img.ColorRgba8 color;
        if (shade < -0.3) {
          color = highlight;
        } else if (shade < 0.15) {
          color = base;
        } else if (shade < 0.5) {
          color = shadow;
        } else {
          color = deep;
        }
        setPixel(image, x, y, color);
      }
    }
  }
}

/// Filled ellipse with anti-aliased edge outline.
void fillAAEllipse(img.Image image, int cx, int cy, int rx, int ry,
    img.ColorRgba8 fill, img.ColorRgba8 outline) {
  if (rx <= 0 || ry <= 0) return;
  for (int y = cy - ry - 1; y <= cy + ry + 1; y++) {
    for (int x = cx - rx - 1; x <= cx + rx + 1; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      final dist = dx * dx + dy * dy;
      if (dist <= 1.0) {
        setPixel(image, x, y, fill);
      } else if (dist <= 1.15) {
        // Anti-aliased edge
        final edgeAlpha = ((1.15 - dist) / 0.15 * outline.a.toInt()).round();
        blendPixel(image, x, y,
            rgba(outline.r.toInt(), outline.g.toInt(), outline.b.toInt(), edgeAlpha.clamp(0, 255)));
      }
    }
  }
}

/// Shaded ellipse with anti-aliased outline — the full 16-bit treatment.
void fillShaded16Ellipse(img.Image image, int cx, int cy, int rx, int ry,
    img.ColorRgba8 base, {img.ColorRgba8? outlineColor}) {
  final highlight = lighten(base, 30);
  final shadow = darken(base, 20);
  final deep = darken(base, 40);
  final outline = outlineColor ?? darken(base, 60);

  if (rx <= 0 || ry <= 0) return;
  for (int y = cy - ry - 1; y <= cy + ry + 1; y++) {
    for (int x = cx - rx - 1; x <= cx + rx + 1; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      final dist = dx * dx + dy * dy;
      if (dist <= 1.0) {
        final shade = dx * 0.5 + dy * 0.5;
        img.ColorRgba8 color;
        if (shade < -0.35) {
          color = highlight;
        } else if (shade < 0.1) {
          color = base;
        } else if (shade < 0.45) {
          color = shadow;
        } else {
          color = deep;
        }
        setPixel(image, x, y, color);
      } else if (dist <= 1.2) {
        final edgeAlpha = ((1.2 - dist) / 0.2 * outline.a.toInt()).round();
        blendPixel(image, x, y,
            rgba(outline.r.toInt(), outline.g.toInt(), outline.b.toInt(), edgeAlpha.clamp(0, 255)));
      }
    }
  }
}

void fillShaded16Circle(
    img.Image image, int cx, int cy, int r, img.ColorRgba8 base,
    {img.ColorRgba8? outlineColor}) {
  fillShaded16Ellipse(image, cx, cy, r, r, base, outlineColor: outlineColor);
}

void drawThickLine(img.Image image, int x1, int y1, int x2, int y2,
    int thickness, img.ColorRgba8 color) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  final steps = max(dx.abs(), dy.abs());
  if (steps == 0) {
    fillCircle(image, x1, y1, thickness ~/ 2, color);
    return;
  }
  for (int i = 0; i <= steps; i++) {
    final x = x1 + (dx * i / steps).round();
    final y = y1 + (dy * i / steps).round();
    final r = thickness ~/ 2;
    for (int py = y - r; py <= y + r; py++) {
      for (int px = x - r; px <= x + r; px++) {
        if ((px - x) * (px - x) + (py - y) * (py - y) <= r * r) {
          setPixel(image, px, py, color);
        }
      }
    }
  }
}

/// Shaded thick line with highlight on one side.
void drawShadedLine(img.Image image, int x1, int y1, int x2, int y2,
    int thickness, img.ColorRgba8 base) {
  final highlight = lighten(base, 25);
  final shadow = darken(base, 25);
  final dx = x2 - x1;
  final dy = y2 - y1;
  final steps = max(dx.abs(), dy.abs());
  if (steps == 0) return;
  final r = thickness ~/ 2;
  for (int i = 0; i <= steps; i++) {
    final cx = x1 + (dx * i / steps).round();
    final cy = y1 + (dy * i / steps).round();
    for (int py = cy - r; py <= cy + r; py++) {
      for (int px = cx - r; px <= cx + r; px++) {
        if ((px - cx) * (px - cx) + (py - cy) * (py - cy) <= r * r) {
          // Shade left side lighter
          final relX = px - cx;
          img.ColorRgba8 c;
          if (relX < -r * 0.3) {
            c = highlight;
          } else if (relX > r * 0.3) {
            c = shadow;
          } else {
            c = base;
          }
          setPixel(image, px, py, c);
        }
      }
    }
  }
}

void fillTriangle(img.Image image, int x1, int y1, int x2, int y2, int x3,
    int y3, img.ColorRgba8 color) {
  final minX = [x1, x2, x3].reduce(min);
  final maxX = [x1, x2, x3].reduce(max);
  final minY = [y1, y2, y3].reduce(min);
  final maxY = [y1, y2, y3].reduce(max);

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      if (_pointInTriangle(x, y, x1, y1, x2, y2, x3, y3)) {
        setPixel(image, x, y, color);
      }
    }
  }
}

bool _pointInTriangle(
    int px, int py, int x1, int y1, int x2, int y2, int x3, int y3) {
  final d1 = (px - x2) * (y1 - y2) - (x1 - x2) * (py - y2);
  final d2 = (px - x3) * (y2 - y3) - (x2 - x3) * (py - y3);
  final d3 = (px - x1) * (y3 - y1) - (x3 - x1) * (py - y1);
  final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
  final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
  return !(hasNeg && hasPos);
}

void fillRect(img.Image image, int x1, int y1, int x2, int y2,
    img.ColorRgba8 color) {
  for (int y = min(y1, y2); y <= max(y1, y2); y++) {
    for (int x = min(x1, x2); x <= max(x1, x2); x++) {
      setPixel(image, x, y, color);
    }
  }
}

/// Filled rectangle with vertical gradient (top color → bottom color).
void fillGradientRect(img.Image image, int x1, int y1, int x2, int y2,
    img.ColorRgba8 topColor, img.ColorRgba8 bottomColor) {
  final height = (y2 - y1).abs();
  if (height == 0) {
    fillRect(image, x1, y1, x2, y2, topColor);
    return;
  }
  final startY = min(y1, y2);
  final endY = max(y1, y2);
  for (int y = startY; y <= endY; y++) {
    final t = (y - startY) / height;
    final r = (topColor.r.toInt() + (bottomColor.r.toInt() - topColor.r.toInt()) * t).round().clamp(0, 255);
    final g = (topColor.g.toInt() + (bottomColor.g.toInt() - topColor.g.toInt()) * t).round().clamp(0, 255);
    final b = (topColor.b.toInt() + (bottomColor.b.toInt() - topColor.b.toInt()) * t).round().clamp(0, 255);
    for (int x = min(x1, x2); x <= max(x1, x2); x++) {
      setPixel(image, x, y, rgba(r, g, b));
    }
  }
}

/// Add a specular highlight dot.
void addHighlight(img.Image image, int x, int y, int radius,
    [int alpha = 180]) {
  for (int dy = -radius; dy <= radius; dy++) {
    for (int dx = -radius; dx <= radius; dx++) {
      final dist = sqrt(dx * dx + dy * dy);
      if (dist <= radius) {
        final a = (alpha * (1 - dist / radius)).round().clamp(0, 255);
        blendPixel(image, x + dx, y + dy, rgba(255, 255, 255, a));
      }
    }
  }
}

// ── Palette constants ──────────────────────────────────────────────────

final skin = rgba(239, 208, 175);
final skinShadow = rgba(210, 170, 135);
final skinDeep = rgba(180, 140, 105);
final eyeColor = rgba(30, 30, 40);
final outlineBlack = rgba(20, 20, 30, 180);

final woodBrown = rgba(130, 90, 50);
final goldAccent = rgba(240, 210, 70);
final silver = rgba(190, 200, 210);
final redAccent = rgba(200, 50, 50);
final blueGlow = rgba(100, 160, 255);
final cyanGlow = rgba(80, 220, 220);
final greenGlow = rgba(80, 230, 80);
final fireOrange = rgba(255, 140, 30);

/// Save a 64x64 image and a 240x240 nearest-neighbor upscale.
void saveSprite(img.Image small, String basePath) {
  final large = img.copyResize(small,
      width: 240, height: 240, interpolation: img.Interpolation.nearest);
  File('$basePath.png').writeAsBytesSync(img.encodePng(small));
  File('${basePath}_large.png').writeAsBytesSync(img.encodePng(large));
}
