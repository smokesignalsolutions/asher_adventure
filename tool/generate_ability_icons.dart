import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'sprite_helpers.dart';

const int S = 32; // icon size
const String outDir = 'assets/sprites/abilities';

// ── Shared helpers for 32x32 ability icons ──────────────────────────────

/// Create a blank 32x32 RGBA image.
img.Image newIcon() => img.Image(width: S, height: S, numChannels: 4);

/// Add a subtle dark circular vignette background so icon is visible on any bg.
void addVignette(img.Image im, {int alpha = 50}) {
  final cx = S ~/ 2, cy = S ~/ 2;
  final r = 14.0;
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      if (dist < r) {
        final a = (alpha * (1 - dist / r) * 0.7).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(10, 10, 20, a));
      }
    }
  }
}

/// Add a diamond-shaped dark vignette.
void addDiamondVignette(img.Image im, {int alpha = 50}) {
  final cx = S ~/ 2, cy = S ~/ 2;
  final r = 14.0;
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = ((x - cx).abs() + (y - cy).abs()).toDouble();
      if (dist < r) {
        final a = (alpha * (1 - dist / r) * 0.7).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(10, 10, 20, a));
      }
    }
  }
}

/// Radial glow around a center point.
void addGlow(img.Image im, int cx, int cy, double radius, img.ColorRgba8 color,
    {int maxAlpha = 80}) {
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      if (dist < radius) {
        final a = (maxAlpha * (1 - dist / radius)).round().clamp(0, 255);
        blendPixel(
            im,
            x,
            y,
            rgba(color.r.toInt(), color.g.toInt(), color.b.toInt(), a));
      }
    }
  }
}

/// Save a 32x32 icon PNG.
void saveIcon(img.Image im, String name) {
  File('$outDir/$name').writeAsBytesSync(img.encodePng(im));
  print('  Generated $name');
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. SWORD
// ═══════════════════════════════════════════════════════════════════════════
img.Image genSword() {
  final im = newIcon();
  addVignette(im);

  // Blade — diagonal from upper-right to lower-left
  final bladeSilver = rgba(200, 210, 220);
  final bladeHi = rgba(230, 240, 255);
  final bladeSh = rgba(150, 160, 175);
  // Blade body: thick diagonal line
  drawThickLine(im, 8, 24, 24, 4, 3, bladeSilver);
  // Highlight edge
  drawThickLine(im, 9, 23, 24, 4, 1, bladeHi);
  // Shadow edge
  drawThickLine(im, 7, 25, 22, 6, 1, bladeSh);
  // Blade tip highlight
  setPixel(im, 25, 3, bladeHi);
  setPixel(im, 24, 3, bladeHi);

  // Crossguard — gold
  final gold = rgba(230, 200, 60);
  final goldHi = rgba(255, 240, 120);
  drawThickLine(im, 6, 19, 14, 21, 2, gold);
  setPixel(im, 6, 19, goldHi);
  setPixel(im, 7, 19, goldHi);

  // Handle — brown
  final brown = rgba(120, 80, 40);
  final brownDk = rgba(90, 60, 30);
  drawThickLine(im, 4, 26, 8, 22, 2, brown);
  drawThickLine(im, 3, 27, 7, 23, 1, brownDk);

  // Pommel
  fillCircle(im, 3, 28, 1, gold);

  // Metallic shine on blade
  addHighlight(im, 18, 10, 2, 160);
  addHighlight(im, 14, 15, 1, 120);

  // Glow
  addGlow(im, 16, 14, 8, rgba(200, 210, 255), maxAlpha: 30);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. SWORD POWER
// ═══════════════════════════════════════════════════════════════════════════
img.Image genSwordPower() {
  final im = genSword(); // start with the regular sword

  // Orange/red energy aura
  addGlow(im, 16, 14, 14, rgba(255, 100, 20), maxAlpha: 70);
  addGlow(im, 16, 14, 10, rgba(255, 60, 20), maxAlpha: 50);

  // Energy wisps — scattered orange/red pixels
  final rng = Random(42);
  for (int i = 0; i < 18; i++) {
    final angle = rng.nextDouble() * 2 * pi;
    final dist = 6 + rng.nextDouble() * 7;
    final x = (16 + cos(angle) * dist).round();
    final y = (14 + sin(angle) * dist).round();
    blendPixel(im, x, y, rgba(255, 140 + rng.nextInt(80), 30, 120));
  }

  // Bright sparks
  blendPixel(im, 22, 6, rgba(255, 255, 100, 180));
  blendPixel(im, 10, 20, rgba(255, 200, 50, 160));
  blendPixel(im, 20, 10, rgba(255, 255, 150, 200));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. DAGGER
// ═══════════════════════════════════════════════════════════════════════════
img.Image genDagger() {
  final im = newIcon();
  addVignette(im);

  // Short curved blade — diagonal
  final bladeSilver = rgba(190, 200, 215);
  final bladeHi = rgba(225, 235, 250);
  drawThickLine(im, 12, 22, 22, 8, 2, bladeSilver);
  drawThickLine(im, 13, 21, 22, 8, 1, bladeHi);
  // Slight curve: extra pixels
  setPixel(im, 21, 8, bladeHi);
  setPixel(im, 22, 7, rgba(180, 190, 210));

  // Dark handle
  final handle = rgba(60, 50, 50);
  final handleHi = rgba(90, 75, 70);
  drawThickLine(im, 8, 25, 12, 22, 2, handle);
  setPixel(im, 9, 24, handleHi);

  // Small crossguard
  final guard = rgba(140, 130, 120);
  drawThickLine(im, 10, 21, 15, 23, 1, guard);

  // Metallic shine
  addHighlight(im, 18, 13, 1, 150);

  // Green poison drip
  final poison = rgba(80, 230, 40);
  setPixel(im, 23, 8, poison);
  setPixel(im, 23, 9, rgba(60, 200, 30, 180));
  setPixel(im, 23, 10, rgba(50, 180, 20, 120));
  blendPixel(im, 24, 9, rgba(60, 200, 30, 80));

  addGlow(im, 22, 9, 4, rgba(80, 230, 40), maxAlpha: 40);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. SHIELD
// ═══════════════════════════════════════════════════════════════════════════
img.Image genShield() {
  final im = newIcon();
  addVignette(im);

  // Kite shield shape — pointed bottom
  final blue = rgba(60, 100, 180);
  final blueHi = rgba(100, 150, 220);
  final blueSh = rgba(40, 70, 140);

  // Main shield body
  for (int y = 5; y < 28; y++) {
    int halfW;
    if (y < 14) {
      halfW = 3 + ((y - 5) * 6 ~/ 9); // widen from top
    } else {
      halfW = 9 - ((y - 14) * 9 ~/ 14); // narrow to point
    }
    halfW = halfW.clamp(0, 10);
    for (int x = 16 - halfW; x <= 16 + halfW; x++) {
      final shade = (x - 16) / (halfW + 1);
      img.ColorRgba8 c;
      if (shade < -0.4) {
        c = blueHi;
      } else if (shade < 0.3) {
        c = blue;
      } else {
        c = blueSh;
      }
      setPixel(im, x, y, c);
    }
  }

  // Gold trim at edges
  final gold = rgba(230, 200, 60);
  for (int y = 5; y < 28; y++) {
    int halfW;
    if (y < 14) {
      halfW = 3 + ((y - 5) * 6 ~/ 9);
    } else {
      halfW = 9 - ((y - 14) * 9 ~/ 14);
    }
    halfW = halfW.clamp(0, 10);
    if (halfW > 0) {
      setPixel(im, 16 - halfW, y, gold);
      setPixel(im, 16 + halfW, y, gold);
    }
  }
  // Top edge
  for (int x = 13; x <= 19; x++) {
    setPixel(im, x, 5, gold);
  }
  // Bottom point
  setPixel(im, 16, 27, gold);

  // Metallic shine
  addHighlight(im, 13, 10, 2, 140);
  addHighlight(im, 14, 14, 1, 100);

  // Silver center line
  final silver = rgba(200, 210, 225);
  for (int y = 7; y < 26; y++) {
    setPixel(im, 16, y, silver);
  }

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. WHIRLWIND
// ═══════════════════════════════════════════════════════════════════════════
img.Image genWhirlwind() {
  final im = newIcon();
  addVignette(im);

  final cyan = rgba(100, 220, 240);
  final white = rgba(220, 240, 255);
  final cyanDk = rgba(60, 160, 200);

  // Spiral pattern — parametric
  final cx = 16.0, cy = 16.0;
  for (int arm = 0; arm < 3; arm++) {
    final startAngle = arm * 2 * pi / 3;
    for (double t = 0; t < 2.5; t += 0.05) {
      final r = 2 + t * 4.5;
      final angle = startAngle + t * 1.8;
      final x = (cx + cos(angle) * r).round();
      final y = (cy + sin(angle) * r).round();
      final thickness = (2.5 - t * 0.6).clamp(1.0, 3.0);
      for (int dy = -(thickness ~/ 1); dy <= thickness ~/ 1; dy++) {
        for (int dx = -(thickness ~/ 1); dx <= thickness ~/ 1; dx++) {
          if (dx * dx + dy * dy <= thickness * thickness) {
            final blend = t < 1.5 ? white : (t < 2.0 ? cyan : cyanDk);
            blendPixel(im, x + dx, y + dy, rgba(blend.r.toInt(), blend.g.toInt(), blend.b.toInt(), 200));
          }
        }
      }
    }
  }

  // Center glow
  addGlow(im, 16, 16, 6, rgba(200, 240, 255), maxAlpha: 80);
  addHighlight(im, 16, 16, 2, 200);

  // Outer glow
  addGlow(im, 16, 16, 14, rgba(100, 220, 240), maxAlpha: 30);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. HEAL
// ═══════════════════════════════════════════════════════════════════════════
img.Image genHeal() {
  final im = newIcon();
  addVignette(im);

  // Green glow background
  addGlow(im, 16, 16, 14, rgba(50, 230, 50), maxAlpha: 50);

  // Green cross
  final green = rgba(50, 220, 50);
  final greenHi = rgba(120, 255, 120);
  final greenSh = rgba(30, 160, 30);

  // Horizontal bar
  fillGradientRect(im, 6, 13, 26, 19, greenHi, greenSh);
  // Vertical bar
  fillGradientRect(im, 13, 6, 19, 26, greenHi, greenSh);

  // Brighter center
  fillRect(im, 13, 13, 19, 19, rgba(140, 255, 140));

  // White center highlight
  addHighlight(im, 16, 16, 3, 220);
  addHighlight(im, 14, 13, 1, 160);

  // Radiating glow
  addGlow(im, 16, 16, 10, rgba(100, 255, 100), maxAlpha: 60);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. HEAL ALL
// ═══════════════════════════════════════════════════════════════════════════
img.Image genHealAll() {
  final im = newIcon();
  addVignette(im);

  addGlow(im, 16, 16, 15, rgba(50, 230, 50), maxAlpha: 40);

  // Central smaller green cross
  final green = rgba(50, 220, 50);
  final greenHi = rgba(120, 255, 120);
  fillRect(im, 9, 14, 23, 18, green);
  fillRect(im, 14, 9, 18, 23, green);
  fillRect(im, 14, 14, 18, 18, greenHi);
  addHighlight(im, 16, 16, 2, 200);

  // Expanding ring/wave effect
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - 16) * (x - 16) + (y - 16) * (y - 16));
      // Ring at radius 12-13
      if (dist > 11 && dist < 13.5) {
        final a = (100 * (1 - ((dist - 12.25).abs() / 1.25))).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(100, 255, 100, a));
      }
      // Inner ring at radius 8-9
      if (dist > 7.5 && dist < 9.5) {
        final a = (70 * (1 - ((dist - 8.5).abs() / 1.0))).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(150, 255, 150, a));
      }
    }
  }

  // Small sparkle dots
  blendPixel(im, 6, 8, rgba(200, 255, 200, 180));
  blendPixel(im, 25, 10, rgba(200, 255, 200, 160));
  blendPixel(im, 8, 24, rgba(200, 255, 200, 140));
  blendPixel(im, 24, 22, rgba(200, 255, 200, 170));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. HOLY
// ═══════════════════════════════════════════════════════════════════════════
img.Image genHoly() {
  final im = newIcon();
  addVignette(im);

  // Warm golden background glow
  addGlow(im, 16, 16, 15, rgba(255, 220, 80), maxAlpha: 50);

  // Radiant star burst — 8 rays
  final gold = rgba(255, 230, 100);
  final goldBright = rgba(255, 250, 200);
  for (int ray = 0; ray < 8; ray++) {
    final angle = ray * pi / 4;
    for (double t = 0; t < 12; t += 0.5) {
      final x = (16 + cos(angle) * t).round();
      final y = (16 + sin(angle) * t).round();
      final a = (200 * (1 - t / 12)).round().clamp(0, 255);
      final c = t < 5 ? goldBright : gold;
      blendPixel(im, x, y, rgba(c.r.toInt(), c.g.toInt(), c.b.toInt(), a));
      // Thicken inner rays
      if (t < 6) {
        blendPixel(im, x + 1, y, rgba(c.r.toInt(), c.g.toInt(), c.b.toInt(), a ~/ 2));
        blendPixel(im, x, y + 1, rgba(c.r.toInt(), c.g.toInt(), c.b.toInt(), a ~/ 2));
      }
    }
  }

  // Bright center
  fillShaded16Circle(im, 16, 16, 4, rgba(255, 240, 160));
  addHighlight(im, 15, 14, 2, 230);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 9. HOLY AOE
// ═══════════════════════════════════════════════════════════════════════════
img.Image genHolyAoe() {
  final im = newIcon();
  addVignette(im);

  addGlow(im, 16, 16, 15, rgba(255, 220, 80), maxAlpha: 40);

  // Expanding golden ring
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - 16) * (x - 16) + (y - 16) * (y - 16));
      // Outer ring
      if (dist > 11 && dist < 14) {
        final a = (140 * (1 - ((dist - 12.5).abs() / 1.5))).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(255, 240, 120, a));
      }
      // Middle ring
      if (dist > 7 && dist < 9.5) {
        final a = (120 * (1 - ((dist - 8.25).abs() / 1.25))).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(255, 250, 180, a));
      }
    }
  }

  // Multiple rays emanating
  for (int ray = 0; ray < 12; ray++) {
    final angle = ray * pi / 6;
    for (double t = 3; t < 14; t += 0.5) {
      final x = (16 + cos(angle) * t).round();
      final y = (16 + sin(angle) * t).round();
      final a = (150 * (1 - t / 14)).round().clamp(0, 255);
      blendPixel(im, x, y, rgba(255, 240, 140, a));
    }
  }

  // Central glow
  fillShaded16Circle(im, 16, 16, 3, rgba(255, 245, 180));
  addHighlight(im, 15, 14, 2, 240);

  // Sparkles at ring edges
  final rng = Random(7);
  for (int i = 0; i < 8; i++) {
    final angle = rng.nextDouble() * 2 * pi;
    final r = 11 + rng.nextDouble() * 3;
    final x = (16 + cos(angle) * r).round();
    final y = (16 + sin(angle) * r).round();
    blendPixel(im, x, y, rgba(255, 255, 220, 200));
  }

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 10. FIREBALL
// ═══════════════════════════════════════════════════════════════════════════
img.Image genFireball() {
  final im = newIcon();
  addVignette(im);

  // Red outer glow
  addGlow(im, 16, 15, 15, rgba(255, 50, 20), maxAlpha: 50);

  // Fire sphere — layered circles
  fillShaded16Circle(im, 16, 15, 9, rgba(200, 40, 10)); // dark red outer
  fillShaded16Circle(im, 16, 15, 7, rgba(240, 100, 20)); // orange mid
  fillShaded16Circle(im, 16, 15, 5, rgba(255, 170, 40)); // bright orange
  fillShaded16Circle(im, 16, 14, 3, rgba(255, 230, 100)); // yellow core
  fillCircle(im, 15, 13, 1, rgba(255, 255, 200)); // white hot center

  addHighlight(im, 14, 12, 2, 200);

  // Flame wisps — small upward tendrils
  final flame = rgba(255, 140, 30);
  final flameHi = rgba(255, 200, 60);
  // Left wisp
  blendPixel(im, 10, 10, rgba(255, 120, 20, 160));
  blendPixel(im, 9, 9, rgba(255, 100, 10, 120));
  blendPixel(im, 9, 8, rgba(255, 80, 10, 80));
  // Right wisp
  blendPixel(im, 22, 10, rgba(255, 120, 20, 140));
  blendPixel(im, 23, 9, rgba(255, 100, 10, 100));
  // Top wisp
  blendPixel(im, 16, 5, rgba(255, 160, 40, 140));
  blendPixel(im, 15, 4, rgba(255, 120, 20, 100));
  blendPixel(im, 17, 4, rgba(255, 100, 10, 80));

  // Bottom trailing sparks
  blendPixel(im, 14, 24, rgba(255, 100, 20, 100));
  blendPixel(im, 18, 25, rgba(255, 80, 10, 80));
  blendPixel(im, 16, 26, rgba(200, 50, 10, 60));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 11. ICE
// ═══════════════════════════════════════════════════════════════════════════
img.Image genIce() {
  final im = newIcon();
  addVignette(im);

  addGlow(im, 16, 16, 14, rgba(80, 200, 255), maxAlpha: 40);

  // Crystal shard — angular shape pointing upward
  final iceBlue = rgba(140, 210, 255);
  final iceHi = rgba(220, 245, 255);
  final iceSh = rgba(60, 140, 200);
  final iceDk = rgba(40, 100, 170);

  // Main crystal — tall triangle
  fillTriangle(im, 16, 3, 10, 22, 16, 28, iceSh); // left face (shadow)
  fillTriangle(im, 16, 3, 22, 22, 16, 28, iceBlue); // right face
  // Highlight face
  fillTriangle(im, 16, 3, 13, 16, 16, 22, iceHi);

  // Secondary shard — left
  fillTriangle(im, 8, 10, 6, 20, 12, 18, iceSh);
  fillTriangle(im, 8, 10, 10, 14, 12, 18, iceHi);

  // Secondary shard — right
  fillTriangle(im, 24, 12, 20, 20, 26, 20, iceBlue);
  fillTriangle(im, 24, 12, 22, 16, 20, 20, iceHi);

  // Specular highlights
  addHighlight(im, 14, 10, 2, 200);
  addHighlight(im, 18, 16, 1, 140);

  // Cold sparkles
  blendPixel(im, 6, 8, rgba(220, 245, 255, 200));
  blendPixel(im, 26, 10, rgba(220, 245, 255, 180));
  blendPixel(im, 12, 4, rgba(255, 255, 255, 160));
  blendPixel(im, 22, 8, rgba(220, 240, 255, 150));

  // Cyan glow around crystal
  addGlow(im, 16, 14, 8, rgba(100, 220, 255), maxAlpha: 50);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 12. LIGHTNING
// ═══════════════════════════════════════════════════════════════════════════
img.Image genLightning() {
  final im = newIcon();
  addVignette(im);

  // Electric glow background
  addGlow(im, 16, 16, 15, rgba(255, 255, 80), maxAlpha: 35);

  final yellow = rgba(255, 255, 100);
  final yellowBright = rgba(255, 255, 220);
  final yellowDk = rgba(200, 200, 40);
  final blueWhite = rgba(200, 220, 255);

  // Lightning bolt — zigzag
  // Segment 1: top to first zag
  drawThickLine(im, 17, 2, 12, 10, 3, yellow);
  drawThickLine(im, 18, 2, 13, 10, 1, yellowBright);
  // Horizontal bar
  drawThickLine(im, 12, 10, 22, 12, 2, yellow);
  drawThickLine(im, 12, 10, 22, 12, 1, yellowBright);
  // Segment 2: zag down
  drawThickLine(im, 22, 12, 14, 20, 3, yellow);
  drawThickLine(im, 22, 12, 15, 20, 1, yellowBright);
  // Lower bar
  drawThickLine(im, 14, 20, 21, 21, 2, yellow);
  // Final point down
  drawThickLine(im, 21, 21, 16, 29, 2, yellow);
  drawThickLine(im, 21, 21, 17, 29, 1, yellowBright);

  // White-hot center line
  setPixel(im, 16, 5, blueWhite);
  setPixel(im, 15, 7, blueWhite);
  setPixel(im, 14, 9, blueWhite);
  setPixel(im, 17, 11, blueWhite);
  setPixel(im, 19, 15, blueWhite);
  setPixel(im, 17, 18, blueWhite);
  setPixel(im, 18, 24, blueWhite);

  // Electric sparks
  final rng = Random(77);
  for (int i = 0; i < 10; i++) {
    final x = 8 + rng.nextInt(16);
    final y = 4 + rng.nextInt(24);
    blendPixel(im, x, y, rgba(255, 255, 180, 60 + rng.nextInt(80)));
  }

  // Blue-white glow along bolt
  addGlow(im, 15, 8, 5, rgba(180, 200, 255), maxAlpha: 40);
  addGlow(im, 18, 16, 5, rgba(180, 200, 255), maxAlpha: 40);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 13. METEOR
// ═══════════════════════════════════════════════════════════════════════════
img.Image genMeteor() {
  final im = newIcon();
  addVignette(im);

  // Background glow — fiery
  addGlow(im, 18, 20, 14, rgba(255, 80, 20), maxAlpha: 35);

  // Fire trail above the rock — streaks going upper-left
  for (double t = 0; t < 12; t += 0.5) {
    final x = (18 - t * 0.8).round();
    final y = (18 - t * 1.2).round();
    final brightness = (1 - t / 12);
    final a = (180 * brightness).round().clamp(0, 255);
    final r = (255 * brightness + 200 * (1 - brightness)).round().clamp(0, 255);
    final g = (200 * brightness * brightness).round().clamp(0, 255);
    blendPixel(im, x, y, rgba(r, g, 10, a));
    blendPixel(im, x - 1, y, rgba(r, g ~/ 2, 10, a ~/ 2));
    blendPixel(im, x + 1, y, rgba(r, g ~/ 2, 10, a ~/ 2));
    blendPixel(im, x, y - 1, rgba(r, g ~/ 2, 10, a ~/ 3));
  }

  // The rock
  final rock = rgba(140, 120, 100);
  final rockDk = rgba(90, 75, 60);
  fillShaded16Circle(im, 18, 21, 6, rock);
  // Cracks/texture on rock
  setPixel(im, 16, 20, rockDk);
  setPixel(im, 19, 22, rockDk);
  setPixel(im, 17, 23, rockDk);
  setPixel(im, 20, 19, rockDk);

  // Orange fire wrap on leading edge
  final fireWrap = rgba(255, 140, 30);
  for (int angle = -60; angle <= 120; angle += 10) {
    final rad = angle * pi / 180;
    final x = (18 + cos(rad) * 7).round();
    final y = (21 + sin(rad) * 7).round();
    blendPixel(im, x, y, rgba(255, 140, 30, 140));
  }

  // Bright impact glow at bottom-right of rock
  addGlow(im, 20, 23, 4, rgba(255, 200, 60), maxAlpha: 70);
  addHighlight(im, 16, 19, 2, 120);

  // Sparks
  blendPixel(im, 12, 12, rgba(255, 200, 60, 150));
  blendPixel(im, 10, 8, rgba(255, 180, 40, 100));
  blendPixel(im, 8, 6, rgba(255, 140, 20, 80));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 14. ARCANE
// ═══════════════════════════════════════════════════════════════════════════
img.Image genArcane() {
  final im = newIcon();
  addVignette(im);

  // Purple glow background
  addGlow(im, 16, 16, 15, rgba(160, 60, 255), maxAlpha: 45);

  // Swirling energy orb
  fillShaded16Circle(im, 16, 16, 8, rgba(100, 30, 180));
  fillShaded16Circle(im, 16, 16, 6, rgba(140, 60, 220));
  fillShaded16Circle(im, 16, 16, 4, rgba(180, 100, 255));
  fillCircle(im, 15, 15, 2, rgba(220, 160, 255));

  addHighlight(im, 14, 13, 2, 200);

  // Magical sparkles — orbiting particles
  final rng = Random(33);
  for (int i = 0; i < 12; i++) {
    final angle = i * pi / 6 + 0.3;
    final r = 9 + rng.nextDouble() * 4;
    final x = (16 + cos(angle) * r).round();
    final y = (16 + sin(angle) * r).round();
    final bright = 160 + rng.nextInt(80);
    blendPixel(im, x, y, rgba(bright, bright ~/ 2, 255, 180));
  }

  // Swirl lines
  for (double t = 0; t < 3; t += 0.08) {
    final angle = t * 2.5;
    final r = 4 + t * 2.5;
    final x = (16 + cos(angle) * r).round();
    final y = (16 + sin(angle) * r).round();
    blendPixel(im, x, y, rgba(200, 140, 255, (150 * (1 - t / 3)).round().clamp(0, 255)));
  }

  // Bright sparks
  blendPixel(im, 10, 8, rgba(255, 200, 255, 200));
  blendPixel(im, 22, 10, rgba(255, 180, 255, 170));
  blendPixel(im, 8, 20, rgba(255, 160, 255, 150));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 15. DARK
// ═══════════════════════════════════════════════════════════════════════════
img.Image genDark() {
  final im = newIcon();
  addVignette(im, alpha: 60);

  // Dark purple glow
  addGlow(im, 16, 16, 15, rgba(80, 20, 120), maxAlpha: 50);

  // Dark void sphere
  fillShaded16Circle(im, 16, 16, 8, rgba(60, 20, 90));
  fillShaded16Circle(im, 16, 16, 6, rgba(40, 10, 70));
  fillCircle(im, 16, 16, 4, rgba(15, 5, 30)); // void center
  fillCircle(im, 16, 16, 2, rgba(5, 0, 10)); // deepest void

  // Sinister purple energy tendrils
  final tendril = rgba(160, 60, 200, 140);
  // Tendril 1 — upper right
  for (double t = 0; t < 8; t += 0.4) {
    final x = (16 + t * 1.1 + sin(t * 1.5) * 1.5).round();
    final y = (16 - t * 0.8 + cos(t * 2) * 1.2).round();
    blendPixel(im, x, y, rgba(160, 60, 200, (140 * (1 - t / 8)).round().clamp(0, 255)));
  }
  // Tendril 2 — lower left
  for (double t = 0; t < 8; t += 0.4) {
    final x = (16 - t * 1.0 + sin(t * 1.3) * 1.5).round();
    final y = (16 + t * 0.9 + cos(t * 1.8) * 1.0).round();
    blendPixel(im, x, y, rgba(140, 40, 180, (130 * (1 - t / 8)).round().clamp(0, 255)));
  }
  // Tendril 3 — upper left
  for (double t = 0; t < 7; t += 0.4) {
    final x = (16 - t * 0.7 + sin(t * 2) * 1.2).round();
    final y = (16 - t * 1.0 + cos(t * 1.5) * 1.5).round();
    blendPixel(im, x, y, rgba(150, 50, 190, (120 * (1 - t / 7)).round().clamp(0, 255)));
  }
  // Tendril 4 — lower right
  for (double t = 0; t < 7; t += 0.4) {
    final x = (16 + t * 0.9 + sin(t * 1.7) * 1.3).round();
    final y = (16 + t * 0.7 + cos(t * 2.1) * 1.0).round();
    blendPixel(im, x, y, rgba(130, 30, 170, (110 * (1 - t / 7)).round().clamp(0, 255)));
  }

  // Faint dark glow around edges
  addGlow(im, 16, 16, 10, rgba(100, 30, 160), maxAlpha: 40);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 16. POISON
// ═══════════════════════════════════════════════════════════════════════════
img.Image genPoison() {
  final im = newIcon();
  addVignette(im);

  // Noxious green glow
  addGlow(im, 16, 16, 15, rgba(80, 200, 30), maxAlpha: 35);

  // Main droplet shape — teardrop
  // Bottom round part
  fillShaded16Circle(im, 16, 18, 7, rgba(40, 180, 30));
  // Darker inner
  fillShaded16Circle(im, 16, 18, 5, rgba(50, 200, 40));
  // Highlight
  fillCircle(im, 14, 16, 2, rgba(100, 230, 80));

  // Top point of droplet
  fillTriangle(im, 16, 6, 12, 14, 20, 14, rgba(60, 190, 40));
  // Highlight on point
  setPixel(im, 15, 9, rgba(120, 240, 100));
  setPixel(im, 15, 10, rgba(100, 230, 90));

  addHighlight(im, 14, 15, 2, 160);

  // Bubbles
  fillShaded16Circle(im, 10, 22, 2, rgba(30, 160, 20));
  addHighlight(im, 9, 21, 1, 140);
  fillShaded16Circle(im, 22, 20, 2, rgba(35, 170, 25));
  addHighlight(im, 21, 19, 1, 130);
  fillCircle(im, 8, 18, 1, rgba(40, 150, 25));
  fillCircle(im, 24, 16, 1, rgba(35, 155, 20));

  // Noxious fumes
  blendPixel(im, 12, 8, rgba(80, 200, 40, 80));
  blendPixel(im, 20, 7, rgba(80, 200, 40, 70));
  blendPixel(im, 18, 5, rgba(70, 190, 30, 60));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 17. SKULL
// ═══════════════════════════════════════════════════════════════════════════
img.Image genSkull() {
  final im = newIcon();
  addVignette(im, alpha: 55);

  // Subtle eerie glow
  addGlow(im, 16, 14, 14, rgba(180, 180, 160), maxAlpha: 25);

  // Skull cranium — wide top
  final bone = rgba(230, 220, 200);
  final boneSh = rgba(190, 180, 160);
  final boneDk = rgba(150, 140, 120);

  fillShaded16Ellipse(im, 16, 12, 9, 8, bone);

  // Jaw — narrower rectangle at bottom
  fillShaded16Ellipse(im, 16, 22, 6, 4, boneSh);

  // Cheek connections
  fillRect(im, 10, 16, 12, 22, boneSh);
  fillRect(im, 20, 16, 22, 22, boneSh);

  // Dark eye sockets
  final eyeDark = rgba(20, 10, 15);
  fillEllipse(im, 12, 12, 3, 3, eyeDark);
  fillEllipse(im, 20, 12, 3, 3, eyeDark);

  // Faint red/green glow in eyes
  blendPixel(im, 12, 12, rgba(180, 40, 30, 100));
  blendPixel(im, 11, 11, rgba(180, 40, 30, 60));
  blendPixel(im, 20, 12, rgba(40, 180, 30, 100));
  blendPixel(im, 19, 11, rgba(40, 180, 30, 60));

  // Nose hole
  fillTriangle(im, 16, 14, 14, 17, 18, 17, eyeDark);

  // Teeth — small white rectangles
  final teeth = rgba(240, 235, 220);
  for (int x = 12; x <= 20; x += 2) {
    fillRect(im, x, 21, x + 1, 24, teeth);
    // Gap between teeth
    if (x < 20) setPixel(im, x + 1, 22, boneDk);
  }

  // Bone highlight
  addHighlight(im, 13, 8, 2, 120);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 18. NATURE
// ═══════════════════════════════════════════════════════════════════════════
img.Image genNature() {
  final im = newIcon();
  addVignette(im);

  // Green energy glow
  addGlow(im, 16, 16, 15, rgba(60, 200, 40), maxAlpha: 40);

  // Leaf shapes arranged in a spiral/circle
  final leafGreen = rgba(50, 180, 40);
  final leafHi = rgba(100, 230, 80);
  final leafDk = rgba(30, 120, 25);

  // Central vine spiral
  for (double t = 0; t < 4; t += 0.1) {
    final angle = t * 1.8;
    final r = 1 + t * 2.5;
    final x = (16 + cos(angle) * r).round();
    final y = (16 + sin(angle) * r).round();
    blendPixel(im, x, y, rgba(60, 140, 30, 200));
  }

  // 6 leaf shapes around the center
  for (int i = 0; i < 6; i++) {
    final angle = i * pi / 3 + 0.2;
    final cx = (16 + cos(angle) * 7).round();
    final cy = (16 + sin(angle) * 7).round();
    // Each leaf is a small ellipse
    fillShaded16Ellipse(im, cx, cy, 3, 2, leafGreen);
    // Leaf vein — lighter center line
    final vx = (cx + cos(angle) * 1).round();
    final vy = (cy + sin(angle) * 1).round();
    blendPixel(im, vx, vy, rgba(100, 230, 80, 180));
  }

  // Center cluster
  fillShaded16Circle(im, 16, 16, 3, rgba(70, 200, 50));
  addHighlight(im, 15, 15, 1, 160);

  // Small sparkle dots for life energy
  blendPixel(im, 8, 10, rgba(180, 255, 140, 180));
  blendPixel(im, 24, 12, rgba(180, 255, 140, 160));
  blendPixel(im, 10, 24, rgba(180, 255, 140, 140));
  blendPixel(im, 22, 22, rgba(180, 255, 140, 170));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 19. SUMMON
// ═══════════════════════════════════════════════════════════════════════════
img.Image genSummon() {
  final im = newIcon();
  addVignette(im);

  // Purple magical glow
  addGlow(im, 16, 16, 15, rgba(140, 50, 220), maxAlpha: 45);

  // Outer portal ring
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - 16) * (x - 16) + (y - 16) * (y - 16));
      // Main ring
      if (dist > 9 && dist < 13) {
        final t = (dist - 9) / 4;
        final a = (180 * (1 - ((t - 0.5).abs() * 2))).round().clamp(0, 255);
        final r = (120 + 60 * t).round().clamp(0, 255);
        blendPixel(im, x, y, rgba(r, 40, 220, a));
      }
    }
  }

  // Arcane rune markers around the ring
  for (int i = 0; i < 6; i++) {
    final angle = i * pi / 3;
    final x = (16 + cos(angle) * 11).round();
    final y = (16 + sin(angle) * 11).round();
    blendPixel(im, x, y, rgba(255, 200, 255, 220));
    blendPixel(im, x + 1, y, rgba(220, 160, 255, 160));
    blendPixel(im, x, y + 1, rgba(220, 160, 255, 160));
  }

  // Bright center — portal opening
  fillShaded16Circle(im, 16, 16, 5, rgba(160, 80, 240));
  fillCircle(im, 16, 16, 3, rgba(200, 140, 255));
  fillCircle(im, 16, 16, 1, rgba(240, 220, 255));
  addHighlight(im, 15, 14, 2, 220);

  // Inner swirl
  for (double t = 0; t < 2; t += 0.1) {
    final angle = t * 3;
    final r = 1 + t * 2;
    final x = (16 + cos(angle) * r).round();
    final y = (16 + sin(angle) * r).round();
    blendPixel(im, x, y, rgba(220, 180, 255, (180 * (1 - t / 2)).round().clamp(0, 255)));
  }

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 20. FIST
// ═══════════════════════════════════════════════════════════════════════════
img.Image genFist() {
  final im = newIcon();
  addDiamondVignette(im);

  // Impact glow
  addGlow(im, 16, 14, 14, rgba(255, 220, 120), maxAlpha: 35);

  // Fist — golden/tan color
  final skin = rgba(220, 180, 120);
  final skinHi = rgba(250, 220, 160);
  final skinSh = rgba(180, 140, 90);
  final skinDk = rgba(140, 100, 60);

  // Main fist body — rounded rectangle shape
  fillShaded16Ellipse(im, 16, 14, 7, 6, skin);

  // Knuckle bumps across the top
  for (int i = 0; i < 4; i++) {
    final kx = 11 + i * 3;
    fillShaded16Circle(im, kx, 9, 2, skinHi);
  }

  // Thumb
  fillShaded16Ellipse(im, 9, 16, 2, 4, skinHi);

  // Finger lines
  for (int i = 0; i < 3; i++) {
    final fx = 12 + i * 3;
    setPixel(im, fx, 13, skinDk);
    setPixel(im, fx, 14, skinDk);
  }

  // Wrist at bottom
  fillShaded16Ellipse(im, 16, 22, 5, 3, skinSh);

  addHighlight(im, 13, 10, 2, 140);

  // Impact lines radiating outward
  final impactLine = rgba(255, 240, 180, 160);
  // Top-left
  drawThickLine(im, 4, 4, 8, 7, 1, impactLine);
  // Top-right
  drawThickLine(im, 28, 4, 24, 7, 1, impactLine);
  // Left
  drawThickLine(im, 2, 14, 6, 14, 1, impactLine);
  // Right
  drawThickLine(im, 26, 14, 30, 14, 1, impactLine);
  // Bottom-left
  drawThickLine(im, 5, 26, 8, 22, 1, rgba(255, 240, 180, 100));
  // Bottom-right
  drawThickLine(im, 27, 26, 24, 22, 1, rgba(255, 240, 180, 100));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 21. ARROW
// ═══════════════════════════════════════════════════════════════════════════
img.Image genArrow() {
  final im = newIcon();
  addVignette(im);

  // Wooden shaft — diagonal upper-right
  final wood = rgba(160, 120, 70);
  final woodHi = rgba(190, 150, 100);
  drawThickLine(im, 5, 26, 24, 7, 2, wood);
  drawThickLine(im, 6, 25, 24, 7, 1, woodHi);

  // Steel arrowhead
  final steel = rgba(200, 210, 220);
  final steelHi = rgba(230, 240, 250);
  fillTriangle(im, 27, 4, 22, 7, 24, 11, steel);
  fillTriangle(im, 27, 4, 24, 5, 23, 7, steelHi);
  // Tip
  setPixel(im, 28, 3, steelHi);

  // Fletching at back
  final fletch = rgba(200, 50, 50);
  final fletchDk = rgba(160, 40, 40);
  // Two feather shapes
  fillTriangle(im, 5, 27, 2, 24, 7, 24, fletch);
  fillTriangle(im, 5, 27, 3, 30, 8, 28, fletchDk);

  // Metallic shine on head
  addHighlight(im, 25, 6, 1, 180);

  // Motion lines
  blendPixel(im, 2, 28, rgba(200, 200, 200, 100));
  blendPixel(im, 1, 29, rgba(200, 200, 200, 80));
  blendPixel(im, 3, 30, rgba(180, 180, 180, 70));
  drawThickLine(im, 1, 22, 4, 22, 1, rgba(200, 200, 200, 80));
  drawThickLine(im, 0, 26, 3, 26, 1, rgba(180, 180, 180, 70));

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 22. ARROW RAIN
// ═══════════════════════════════════════════════════════════════════════════
img.Image genArrowRain() {
  final im = newIcon();
  addVignette(im);

  final wood = rgba(160, 120, 70);
  final steel = rgba(200, 210, 220);
  final steelHi = rgba(230, 240, 250);

  // Draw several arrows falling from upper area, angled downward
  void drawSmallArrow(int x1, int y1, int x2, int y2, int alpha) {
    // Shaft
    drawThickLine(im, x1, y1, x2, y2, 1,
        rgba(wood.r.toInt(), wood.g.toInt(), wood.b.toInt(), alpha));
    // Arrowhead at (x2,y2) — just a couple pixels
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1) return;
    final nx = dx / len;
    final ny = dy / len;
    final tipX = (x2 + nx * 2).round();
    final tipY = (y2 + ny * 2).round();
    blendPixel(im, tipX, tipY, rgba(steel.r.toInt(), steel.g.toInt(), steel.b.toInt(), alpha));
    blendPixel(im, tipX - 1, tipY, rgba(steel.r.toInt(), steel.g.toInt(), steel.b.toInt(), alpha ~/ 2));
    blendPixel(im, tipX + 1, tipY, rgba(steel.r.toInt(), steel.g.toInt(), steel.b.toInt(), alpha ~/ 2));
    // Fletching at tail
    blendPixel(im, x1 - 1, y1, rgba(200, 50, 50, alpha ~/ 2));
    blendPixel(im, x1 + 1, y1, rgba(200, 50, 50, alpha ~/ 2));
  }

  // Arrow 1 — center, most visible
  drawSmallArrow(12, 2, 14, 18, 240);
  blendPixel(im, 14, 20, rgba(200, 210, 220, 240));
  // Arrow 2 — right
  drawSmallArrow(20, 4, 21, 20, 220);
  blendPixel(im, 21, 22, rgba(200, 210, 220, 220));
  // Arrow 3 — left
  drawSmallArrow(7, 5, 9, 21, 200);
  blendPixel(im, 9, 23, rgba(200, 210, 220, 200));
  // Arrow 4 — far right, slightly behind
  drawSmallArrow(25, 1, 26, 14, 160);
  blendPixel(im, 26, 16, rgba(200, 210, 220, 160));
  // Arrow 5 — far left
  drawSmallArrow(3, 3, 5, 16, 140);
  blendPixel(im, 5, 18, rgba(200, 210, 220, 140));

  // Ground impact lines at bottom
  blendPixel(im, 14, 26, rgba(180, 160, 120, 120));
  blendPixel(im, 13, 27, rgba(180, 160, 120, 80));
  blendPixel(im, 15, 27, rgba(180, 160, 120, 80));
  blendPixel(im, 21, 27, rgba(180, 160, 120, 100));
  blendPixel(im, 9, 28, rgba(180, 160, 120, 100));

  // Subtle sky glow at top
  addGlow(im, 16, 0, 12, rgba(180, 180, 200), maxAlpha: 20);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// 23. BOMB
// ═══════════════════════════════════════════════════════════════════════════
img.Image genBomb() {
  final im = newIcon();
  addVignette(im);

  // Warm glow from fuse
  addGlow(im, 20, 6, 8, rgba(255, 180, 40), maxAlpha: 40);

  // Round black bomb body
  final bombBlack = rgba(40, 35, 40);
  fillShaded16Circle(im, 15, 18, 9, bombBlack);

  // Subtle sheen on bomb
  addHighlight(im, 12, 14, 3, 60);

  // Dark outline ring for definition
  for (int y = 0; y < S; y++) {
    for (int x = 0; x < S; x++) {
      final dist = sqrt((x - 15) * (x - 15) + (y - 18) * (y - 18));
      if (dist > 8.5 && dist < 10) {
        blendPixel(im, x, y, rgba(20, 15, 20, 120));
      }
    }
  }

  // Fuse tube coming out of top
  final fuseGray = rgba(100, 90, 80);
  drawThickLine(im, 18, 10, 22, 6, 2, fuseGray);

  // Fuse string — thin curvy line
  final fuseString = rgba(160, 140, 100);
  setPixel(im, 22, 6, fuseString);
  setPixel(im, 23, 5, fuseString);
  setPixel(im, 24, 5, fuseString);
  setPixel(im, 24, 4, fuseString);
  setPixel(im, 25, 4, fuseString);

  // Spark at fuse tip
  final spark = rgba(255, 200, 50);
  final sparkBright = rgba(255, 255, 180);
  fillCircle(im, 25, 3, 2, spark);
  setPixel(im, 25, 2, sparkBright);
  setPixel(im, 25, 3, sparkBright);
  addHighlight(im, 25, 3, 1, 240);

  // Spark glow
  addGlow(im, 25, 3, 5, rgba(255, 200, 50), maxAlpha: 90);

  // Small sparks flying off
  blendPixel(im, 27, 2, rgba(255, 240, 100, 160));
  blendPixel(im, 23, 1, rgba(255, 220, 80, 140));
  blendPixel(im, 26, 5, rgba(255, 200, 60, 120));
  blendPixel(im, 28, 4, rgba(255, 180, 40, 100));

  // Metal band on top of bomb
  final metal = rgba(130, 130, 140);
  drawThickLine(im, 13, 10, 19, 10, 1, metal);

  return im;
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════
void main() {
  Directory(outDir).createSync(recursive: true);
  print('Generating 23 ability icons (32x32, vibrant 16-bit style)...\n');

  saveIcon(genSword(), 'sword.png');
  saveIcon(genSwordPower(), 'sword_power.png');
  saveIcon(genDagger(), 'dagger.png');
  saveIcon(genShield(), 'shield.png');
  saveIcon(genWhirlwind(), 'whirlwind.png');
  saveIcon(genHeal(), 'heal.png');
  saveIcon(genHealAll(), 'heal_all.png');
  saveIcon(genHoly(), 'holy.png');
  saveIcon(genHolyAoe(), 'holy_aoe.png');
  saveIcon(genFireball(), 'fireball.png');
  saveIcon(genIce(), 'ice.png');
  saveIcon(genLightning(), 'lightning.png');
  saveIcon(genMeteor(), 'meteor.png');
  saveIcon(genArcane(), 'arcane.png');
  saveIcon(genDark(), 'dark.png');
  saveIcon(genPoison(), 'poison.png');
  saveIcon(genSkull(), 'skull.png');
  saveIcon(genNature(), 'nature.png');
  saveIcon(genSummon(), 'summon.png');
  saveIcon(genFist(), 'fist.png');
  saveIcon(genArrow(), 'arrow.png');
  saveIcon(genArrowRain(), 'arrow_rain.png');
  saveIcon(genBomb(), 'bomb.png');

  print('\nDone! All 23 ability icons generated in $outDir/');
}
