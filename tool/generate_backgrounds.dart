import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'sprite_helpers.dart';

// Background size
const int W = 320;
const int H = 180;

final _rng = Random(42);

// ── Helper: save a single background PNG ─────────────────────────────
void saveBg(img.Image image, String name) {
  final path = 'assets/sprites/backgrounds/$name.png';
  File(path).writeAsBytesSync(img.encodePng(image));
  print('  ✓ $path');
}

// ── Helper: draw a wavy horizontal band (for hills, dunes, etc.) ─────
void fillWavyBand(img.Image image, int baseY, int amplitude, double freq,
    img.ColorRgba8 color, int bottomY,
    {double phase = 0.0}) {
  for (int x = 0; x < W; x++) {
    final waveY =
        baseY + (sin(x * freq + phase) * amplitude).round();
    for (int y = waveY; y <= bottomY; y++) {
      setPixel(image, x, y, color);
    }
  }
}

// ── Helper: blend a semi-transparent horizontal band (fog, mist) ─────
void fillFogBand(img.Image image, int y1, int y2, img.ColorRgba8 color) {
  for (int y = y1; y <= y2; y++) {
    // Fade alpha toward edges of band
    final mid = (y1 + y2) / 2;
    final dist = (y - mid).abs() / ((y2 - y1) / 2 + 1);
    final a = (color.a.toInt() * (1.0 - dist * 0.6)).round().clamp(0, 255);
    for (int x = 0; x < W; x++) {
      blendPixel(
          image, x, y, rgba(color.r.toInt(), color.g.toInt(), color.b.toInt(), a));
    }
  }
}

// ── 1. Meadow ────────────────────────────────────────────────────────
img.Image generateMeadow() {
  final image = img.Image(width: W, height: H);

  // Sky gradient: darker blue top → lighter blue bottom
  fillGradientRect(image, 0, 0, W - 1, 100, rgba(70, 130, 210), rgba(150, 200, 240));

  // Distant hills (lighter green, atmospheric perspective)
  fillWavyBand(image, 85, 8, 0.015, rgba(160, 200, 140), 110, phase: 1.0);
  fillWavyBand(image, 90, 6, 0.02, rgba(140, 185, 120), 115, phase: 2.5);

  // Mid-ground hills (richer green)
  fillWavyBand(image, 100, 10, 0.012, rgba(100, 170, 70), 130, phase: 0.5);
  fillWavyBand(image, 108, 8, 0.018, rgba(80, 150, 55), 140, phase: 3.0);

  // Foreground grass
  fillGradientRect(image, 0, 130, W - 1, H - 1, rgba(70, 140, 45), rgba(90, 120, 50));

  // Ground texture: warm brown at very bottom
  fillGradientRect(image, 0, 165, W - 1, H - 1, rgba(100, 130, 55), rgba(120, 100, 60));

  // Grass tufts
  for (int i = 0; i < 60; i++) {
    final gx = _rng.nextInt(W);
    final gy = 135 + _rng.nextInt(40);
    final gc = _rng.nextBool() ? rgba(60, 130, 40) : rgba(50, 110, 35);
    setPixel(image, gx, gy, gc);
    setPixel(image, gx, gy - 1, gc);
    if (_rng.nextBool()) setPixel(image, gx, gy - 2, gc);
  }

  // Yellow flowers scattered
  for (int i = 0; i < 25; i++) {
    final fx = _rng.nextInt(W);
    final fy = 130 + _rng.nextInt(35);
    setPixel(image, fx, fy, rgba(240, 220, 60));
    setPixel(image, fx + 1, fy, rgba(255, 240, 80));
  }

  // A few white flowers
  for (int i = 0; i < 10; i++) {
    final fx = _rng.nextInt(W);
    final fy = 132 + _rng.nextInt(30);
    setPixel(image, fx, fy, rgba(255, 255, 240));
  }

  // Soft clouds in sky
  for (final cx in [60, 170, 260]) {
    final cy = 25 + _rng.nextInt(20);
    fillEllipse(image, cx, cy, 20, 6, rgba(255, 255, 255, 140));
    fillEllipse(image, cx + 12, cy - 3, 14, 5, rgba(255, 255, 255, 120));
    fillEllipse(image, cx - 10, cy + 2, 12, 4, rgba(255, 255, 255, 100));
  }

  // Sun highlight top-right
  addHighlight(image, 280, 20, 12, 100);

  return image;
}

// ── 2. Forest ────────────────────────────────────────────────────────
img.Image generateForest() {
  final image = img.Image(width: W, height: H);

  // Dark canopy sky gradient
  fillGradientRect(image, 0, 0, W - 1, 50, rgba(20, 50, 20), rgba(40, 80, 40));

  // Dense canopy layer
  fillGradientRect(image, 0, 0, W - 1, 30, rgba(25, 60, 25), rgba(35, 75, 35));

  // Foliage canopy clusters at top
  for (int x = 0; x < W; x += 12) {
    final cSize = 10 + _rng.nextInt(8);
    final cy = 15 + _rng.nextInt(20);
    fillEllipse(image, x, cy, cSize, cSize - 3, rgba(30, 70 + _rng.nextInt(30), 30));
  }

  // Filtered light through canopy (dappled light effect)
  fillGradientRect(image, 0, 35, W - 1, 80, rgba(40, 80, 40, 180), rgba(50, 90, 40, 100));

  // Mid-ground area
  fillGradientRect(image, 0, 80, W - 1, H - 1, rgba(35, 55, 25), rgba(45, 40, 25));

  // Tree trunks (4 trees at varying positions)
  final trunkData = [
    [50, 40, 140, 5],   // x, topY, bottomY, halfWidth
    [130, 30, 155, 6],
    [210, 45, 160, 4],
    [280, 35, 150, 5],
  ];
  for (final t in trunkData) {
    final tx = t[0], topY = t[1], botY = t[2], hw = t[3];
    // Trunk with shading
    for (int y = topY; y <= botY; y++) {
      for (int x = tx - hw; x <= tx + hw; x++) {
        final shade = (x - tx) / hw;
        img.ColorRgba8 c;
        if (shade < -0.3) {
          c = rgba(100, 70, 40); // highlight
        } else if (shade > 0.3) {
          c = rgba(55, 35, 20); // shadow
        } else {
          c = rgba(80, 55, 30); // base
        }
        setPixel(image, x, y, c);
      }
    }
    // Bark texture
    for (int i = 0; i < 8; i++) {
      final bx = tx - hw + _rng.nextInt(hw * 2);
      final by = topY + _rng.nextInt(botY - topY);
      setPixel(image, bx, by, rgba(60, 40, 20));
    }
  }

  // Foliage on trees (clusters of different greens)
  for (final t in trunkData) {
    final tx = t[0], topY = t[1];
    for (int j = 0; j < 5; j++) {
      final fx = tx + _rng.nextInt(30) - 15;
      final fy = topY - 5 + _rng.nextInt(25);
      final fr = 8 + _rng.nextInt(10);
      final green = 70 + _rng.nextInt(60);
      fillEllipse(image, fx, fy, fr, fr - 2, rgba(25, green, 20));
    }
  }

  // Forest floor: scattered leaves
  for (int i = 0; i < 40; i++) {
    final lx = _rng.nextInt(W);
    final ly = 140 + _rng.nextInt(35);
    final c = _rng.nextBool() ? rgba(100, 70, 30) : rgba(80, 90, 30);
    setPixel(image, lx, ly, c);
  }

  // Light rays (subtle)
  for (int i = 0; i < 3; i++) {
    final rx = 80 + _rng.nextInt(160);
    for (int y = 30; y < 100; y++) {
      final x = rx + ((y - 30) * 0.2).round();
      blendPixel(image, x, y, rgba(200, 220, 150, 15));
      blendPixel(image, x + 1, y, rgba(200, 220, 150, 10));
    }
  }

  return image;
}

// ── 3. Swamp ─────────────────────────────────────────────────────────
img.Image generateSwamp() {
  final image = img.Image(width: W, height: H);

  // Gloomy gray-green sky
  fillGradientRect(image, 0, 0, W - 1, 70, rgba(60, 70, 60), rgba(90, 105, 80));

  // Murky mid-ground
  fillGradientRect(image, 0, 70, W - 1, 100, rgba(60, 75, 50), rgba(50, 65, 40));

  // Murky water at bottom
  fillGradientRect(image, 0, 100, W - 1, H - 1, rgba(50, 70, 45), rgba(40, 55, 35));

  // Water reflections/ripples
  for (int i = 0; i < 30; i++) {
    final rx = _rng.nextInt(W - 10);
    final ry = 105 + _rng.nextInt(70);
    for (int dx = 0; dx < 5 + _rng.nextInt(8); dx++) {
      blendPixel(image, rx + dx, ry, rgba(70, 90, 55, 80));
    }
  }

  // Dead/twisted trees
  void drawGnarledTree(int baseX, int baseY, int height) {
    final trunkColor = rgba(60, 45, 30);
    final darkTrunk = rgba(40, 30, 20);
    // Main trunk (slightly curved)
    for (int y = baseY; y > baseY - height; y--) {
      final sway = (sin((baseY - y) * 0.05) * 3).round();
      final w = max(1, 3 - (baseY - y) ~/ (height ~/ 3));
      for (int dx = -w; dx <= w; dx++) {
        setPixel(image, baseX + sway + dx, y, dx < 0 ? trunkColor : darkTrunk);
      }
    }
    // Branches (thin, twisted)
    final topY = baseY - height;
    for (int b = 0; b < 3; b++) {
      final branchY = topY + _rng.nextInt(height ~/ 2);
      final dir = _rng.nextBool() ? 1 : -1;
      for (int i = 0; i < 15 + _rng.nextInt(10); i++) {
        final bx = baseX + (sin(branchY * 0.05) * 3).round() + dir * i;
        final by = branchY - i ~/ 3 + (sin(i * 0.3) * 2).round();
        setPixel(image, bx, by, trunkColor);
      }
    }
  }

  drawGnarledTree(50, 130, 70);
  drawGnarledTree(160, 125, 60);
  drawGnarledTree(260, 135, 65);
  drawGnarledTree(110, 120, 50);

  // Hanging moss on trees
  for (final tx in [50, 160, 260]) {
    for (int m = 0; m < 4; m++) {
      final mx = tx - 8 + _rng.nextInt(16);
      final my = 65 + _rng.nextInt(30);
      for (int dy = 0; dy < 5 + _rng.nextInt(5); dy++) {
        setPixel(image, mx, my + dy, rgba(70, 90, 50, 160));
      }
    }
  }

  // Fog/mist bands
  fillFogBand(image, 60, 80, rgba(140, 160, 130, 60));
  fillFogBand(image, 90, 105, rgba(120, 140, 110, 50));

  // Lily pads on water
  for (int i = 0; i < 8; i++) {
    final lx = 20 + _rng.nextInt(W - 40);
    final ly = 115 + _rng.nextInt(50);
    fillEllipse(image, lx, ly, 3, 2, rgba(50, 100, 40));
    setPixel(image, lx + 1, ly, rgba(60, 120, 50)); // highlight
  }

  // Bubbles in water
  for (int i = 0; i < 5; i++) {
    final bx = _rng.nextInt(W);
    final by = 110 + _rng.nextInt(60);
    setPixel(image, bx, by, rgba(80, 100, 70, 150));
  }

  return image;
}

// ── 4. Desert ────────────────────────────────────────────────────────
img.Image generateDesert() {
  final image = img.Image(width: W, height: H);

  // Orange-yellow sky gradient
  fillGradientRect(image, 0, 0, W - 1, 70, rgba(200, 120, 50), rgba(240, 200, 100));

  // Sun glow
  addHighlight(image, 250, 25, 18, 120);
  fillCircle(image, 250, 25, 8, rgba(255, 240, 200));

  // Distant rock formations/mesas (dark red-brown, atmospheric haze)
  fillRect(image, 30, 50, 60, 75, rgba(160, 100, 70, 200));
  fillRect(image, 35, 45, 55, 50, rgba(150, 90, 65, 180));
  // Mesa cap
  fillRect(image, 28, 48, 62, 52, rgba(140, 85, 60, 190));

  fillRect(image, 200, 55, 240, 75, rgba(150, 95, 65, 190));
  fillRect(image, 205, 48, 235, 55, rgba(140, 85, 58, 180));

  // Sand dunes (rolling golden hills)
  fillWavyBand(image, 68, 6, 0.01, rgba(220, 190, 130, 200), 90, phase: 1.0);
  fillWavyBand(image, 75, 8, 0.015, rgba(210, 180, 120), 100, phase: 2.0);
  fillWavyBand(image, 85, 10, 0.012, rgba(200, 170, 110), 115, phase: 0.5);

  // Main sand ground
  fillGradientRect(image, 0, 100, W - 1, H - 1, rgba(215, 185, 125), rgba(195, 165, 105));

  // Dune highlights (lighter sand on crests)
  fillWavyBand(image, 100, 5, 0.02, rgba(230, 200, 145), 108, phase: 3.0);

  // Heat shimmer (subtle color variation bands)
  for (int y = 70; y < 95; y += 3) {
    for (int x = 0; x < W; x++) {
      if (_rng.nextInt(3) == 0) {
        blendPixel(image, x, y, rgba(255, 230, 180, 20));
      }
    }
  }

  // Small rocks on sand
  for (int i = 0; i < 15; i++) {
    final rx = _rng.nextInt(W);
    final ry = 110 + _rng.nextInt(60);
    setPixel(image, rx, ry, rgba(160, 130, 80));
    setPixel(image, rx + 1, ry, rgba(150, 120, 75));
  }

  // Sand texture
  for (int i = 0; i < 80; i++) {
    final sx = _rng.nextInt(W);
    final sy = 100 + _rng.nextInt(75);
    setPixel(image, sx, sy, rgba(225, 195, 140));
  }

  // Distant sand swirl
  for (int i = 0; i < 12; i++) {
    final x = 140 + _rng.nextInt(40);
    final y = 60 + _rng.nextInt(10);
    blendPixel(image, x, y, rgba(220, 200, 150, 60));
  }

  return image;
}

// ── 5. Ruins ─────────────────────────────────────────────────────────
img.Image generateRuins() {
  final image = img.Image(width: W, height: H);

  // Overcast gray sky
  fillGradientRect(image, 0, 0, W - 1, 80, rgba(120, 120, 130), rgba(160, 160, 165));

  // Distant fog/haze
  fillGradientRect(image, 0, 70, W - 1, 95, rgba(150, 150, 150, 180), rgba(130, 135, 120, 100));

  // Ground: mossy stone
  fillGradientRect(image, 0, 95, W - 1, H - 1, rgba(100, 110, 90), rgba(80, 85, 70));

  // Stone floor texture
  for (int i = 0; i < 50; i++) {
    final sx = _rng.nextInt(W);
    final sy = 100 + _rng.nextInt(75);
    setPixel(image, sx, sy, rgba(90, 95, 80));
  }

  // Broken stone pillars
  void drawPillar(int x, int topY, int botY, int width, {bool broken = false}) {
    final stoneBase = rgba(140, 140, 145);
    final stoneDark = rgba(110, 110, 118);
    final stoneLight = rgba(165, 165, 170);
    // Main body
    for (int py = topY; py <= botY; py++) {
      for (int px = x - width; px <= x + width; px++) {
        final shade = (px - x) / width;
        if (shade < -0.3) {
          setPixel(image, px, py, stoneLight);
        } else if (shade > 0.4) {
          setPixel(image, px, py, stoneDark);
        } else {
          setPixel(image, px, py, stoneBase);
        }
      }
    }
    // Top cap
    fillRect(image, x - width - 2, topY - 2, x + width + 2, topY, stoneLight);
    // Broken top: jagged edge
    if (broken) {
      for (int px = x - width - 2; px <= x + width + 2; px++) {
        final jag = _rng.nextInt(4);
        for (int dy = 0; dy < jag; dy++) {
          setPixel(image, px, topY - 2 - dy, rgba(0, 0, 0, 0)); // erase top
        }
      }
    }
    // Cracks
    for (int c = 0; c < 3; c++) {
      final cx = x - width + _rng.nextInt(width * 2);
      final cy = topY + _rng.nextInt(botY - topY);
      for (int d = 0; d < 5 + _rng.nextInt(5); d++) {
        setPixel(image, cx + _rng.nextInt(3) - 1, cy + d, rgba(80, 80, 85));
      }
    }
  }

  drawPillar(45, 40, 150, 6, broken: true);
  drawPillar(120, 55, 155, 5, broken: true);
  drawPillar(200, 35, 145, 7, broken: false);
  drawPillar(275, 50, 152, 5, broken: true);

  // Broken wall segment
  fillRect(image, 140, 70, 185, 140, rgba(130, 130, 135));
  fillRect(image, 142, 72, 183, 138, rgba(120, 120, 125));
  // Wall cracks
  for (int i = 0; i < 5; i++) {
    final cx = 142 + _rng.nextInt(40);
    final cy = 72 + _rng.nextInt(60);
    for (int d = 0; d < 8; d++) {
      setPixel(image, cx + _rng.nextInt(3) - 1, cy + d, rgba(90, 90, 95));
    }
  }

  // Ivy/green overgrowth on stones
  for (final px in [45, 120, 200, 275, 160]) {
    for (int i = 0; i < 6; i++) {
      final ix = px + _rng.nextInt(16) - 8;
      final iy = 50 + _rng.nextInt(60);
      fillCircle(image, ix, iy, 2, rgba(50, 100, 40, 180));
      setPixel(image, ix + 1, iy - 1, rgba(70, 130, 55, 160));
    }
  }

  // Scattered rubble on ground
  for (int i = 0; i < 20; i++) {
    final rx = _rng.nextInt(W);
    final ry = 130 + _rng.nextInt(40);
    fillRect(image, rx, ry, rx + 2 + _rng.nextInt(3), ry + 1 + _rng.nextInt(2),
        rgba(130, 130, 135));
  }

  // Moss patches
  for (int i = 0; i < 15; i++) {
    final mx = _rng.nextInt(W);
    final my = 110 + _rng.nextInt(60);
    setPixel(image, mx, my, rgba(60, 90, 40));
    setPixel(image, mx + 1, my, rgba(55, 85, 38));
  }

  return image;
}

// ── 6. Mountain ──────────────────────────────────────────────────────
img.Image generateMountain() {
  final image = img.Image(width: W, height: H);

  // Deep blue sky
  fillGradientRect(image, 0, 0, W - 1, 80, rgba(40, 60, 140), rgba(80, 120, 190));

  // Clouds
  fillEllipse(image, 60, 25, 22, 7, rgba(255, 255, 255, 100));
  fillEllipse(image, 75, 22, 15, 5, rgba(255, 255, 255, 80));
  fillEllipse(image, 240, 35, 18, 6, rgba(255, 255, 255, 90));
  fillEllipse(image, 255, 32, 12, 4, rgba(255, 255, 255, 70));

  // Distant mountain (lighter, hazy - atmospheric perspective)
  fillTriangle(image, 80, 85, 160, 30, 240, 85, rgba(140, 150, 170));
  // Snow cap
  fillTriangle(image, 140, 50, 160, 30, 180, 50, rgba(220, 225, 235));

  // Mid mountain (slightly darker)
  fillTriangle(image, -20, 100, 80, 40, 180, 100, rgba(110, 105, 100));
  // Snow cap
  fillTriangle(image, 55, 60, 80, 40, 105, 60, rgba(210, 215, 225));

  // Right mountain
  fillTriangle(image, 180, 105, 280, 35, 340, 105, rgba(100, 95, 90));
  // Snow cap
  fillTriangle(image, 258, 55, 280, 35, 302, 55, rgba(215, 220, 230));

  // Rocky terrain mid-ground
  fillGradientRect(image, 0, 95, W - 1, 130, rgba(95, 85, 75), rgba(85, 75, 65));

  // Rocky texture in mid-ground
  for (int i = 0; i < 30; i++) {
    final rx = _rng.nextInt(W);
    final ry = 95 + _rng.nextInt(35);
    final rc = _rng.nextBool() ? rgba(80, 75, 65) : rgba(105, 95, 85);
    fillRect(image, rx, ry, rx + 2 + _rng.nextInt(3), ry + 1 + _rng.nextInt(2), rc);
  }

  // Mountain path/ledge foreground
  fillGradientRect(image, 0, 130, W - 1, H - 1, rgba(90, 80, 65), rgba(70, 65, 50));

  // Path stones (lighter strip)
  fillRect(image, 0, 145, W - 1, 160, rgba(110, 100, 80));
  for (int x = 0; x < W; x += 8 + _rng.nextInt(5)) {
    fillRect(image, x, 145, x + 5 + _rng.nextInt(4), 160, rgba(105, 95, 75));
    // Stone borders
    for (int sy = 145; sy <= 160; sy++) {
      setPixel(image, x, sy, rgba(85, 78, 65));
    }
  }

  // Small rocks along path
  for (int i = 0; i < 12; i++) {
    final rx = _rng.nextInt(W);
    final ry = 135 + _rng.nextInt(10);
    fillEllipse(image, rx, ry, 2, 1, rgba(100, 90, 75));
  }

  return image;
}

// ── 7. Cave ──────────────────────────────────────────────────────────
img.Image generateCave() {
  final image = img.Image(width: W, height: H);

  // Dark background
  fillRect(image, 0, 0, W - 1, H - 1, rgba(25, 20, 18));

  // Ceiling gradient (dark to slightly lighter)
  fillGradientRect(image, 0, 0, W - 1, 40, rgba(20, 18, 15), rgba(35, 30, 25));

  // Walls (dark gray/brown, lighter near light sources)
  fillGradientRect(image, 0, 40, W - 1, H - 1, rgba(40, 35, 28), rgba(35, 30, 22));

  // Floor (slightly different tone)
  fillGradientRect(image, 0, 140, W - 1, H - 1, rgba(45, 38, 30), rgba(38, 32, 25));

  // Stalactites hanging from ceiling
  for (int i = 0; i < 12; i++) {
    final sx = 15 + _rng.nextInt(W - 30);
    final sLen = 8 + _rng.nextInt(15);
    final sColor = rgba(55, 50, 42);
    for (int y = 0; y < sLen; y++) {
      final w = max(0, 3 - y ~/ 4);
      for (int dx = -w; dx <= w; dx++) {
        setPixel(image, sx + dx, y, sColor);
      }
    }
    // Drip highlight
    setPixel(image, sx, sLen, rgba(70, 65, 55));
  }

  // Stalagmites rising from floor
  for (int i = 0; i < 10; i++) {
    final sx = 10 + _rng.nextInt(W - 20);
    final sLen = 6 + _rng.nextInt(12);
    final sColor = rgba(50, 45, 38);
    for (int y = 0; y < sLen; y++) {
      final w = max(0, 3 - y ~/ 4);
      for (int dx = -w; dx <= w; dx++) {
        setPixel(image, sx + dx, H - 1 - y, sColor);
      }
    }
  }

  // Rocky wall texture
  for (int i = 0; i < 100; i++) {
    final rx = _rng.nextInt(W);
    final ry = _rng.nextInt(H);
    final rc = rgba(30 + _rng.nextInt(20), 25 + _rng.nextInt(15), 20 + _rng.nextInt(12));
    setPixel(image, rx, ry, rc);
  }

  // Torch 1 (left wall)
  final torch1X = 80;
  final torch1Y = 70;
  // Torch bracket
  fillRect(image, torch1X - 1, torch1Y, torch1X + 1, torch1Y + 8, rgba(100, 70, 40));
  // Flame
  fillEllipse(image, torch1X, torch1Y - 2, 2, 3, rgba(255, 160, 40));
  setPixel(image, torch1X, torch1Y - 4, rgba(255, 200, 80));
  // Torch glow
  addHighlight(image, torch1X, torch1Y - 2, 25, 60);

  // Torch 2 (right wall)
  final torch2X = 240;
  final torch2Y = 75;
  fillRect(image, torch2X - 1, torch2Y, torch2X + 1, torch2Y + 8, rgba(100, 70, 40));
  fillEllipse(image, torch2X, torch2Y - 2, 2, 3, rgba(255, 160, 40));
  setPixel(image, torch2X, torch2Y - 4, rgba(255, 200, 80));
  addHighlight(image, torch2X, torch2Y - 2, 25, 60);

  // Warm light pools on floor beneath torches
  for (final tx in [torch1X, torch2X]) {
    for (int dy = 0; dy < 30; dy++) {
      for (int dx = -15; dx <= 15; dx++) {
        final dist = sqrt(dx * dx + dy * dy.toDouble());
        if (dist < 25) {
          final a = (30 * (1 - dist / 25)).round().clamp(0, 255);
          blendPixel(image, tx + dx, 130 + dy, rgba(255, 150, 50, a));
        }
      }
    }
  }

  // Mineral veins in walls (subtle colored streaks)
  for (int i = 0; i < 5; i++) {
    final vx = _rng.nextInt(W);
    final vy = 40 + _rng.nextInt(80);
    for (int d = 0; d < 10 + _rng.nextInt(10); d++) {
      setPixel(image, vx + d, vy + _rng.nextInt(3) - 1, rgba(70, 60, 50));
    }
  }

  return image;
}

// ── 8. Snow ──────────────────────────────────────────────────────────
img.Image generateSnow() {
  final image = img.Image(width: W, height: H);

  // Pale blue-white sky
  fillGradientRect(image, 0, 0, W - 1, 80, rgba(170, 190, 210), rgba(200, 215, 230));

  // Distant snow-covered hills (very light)
  fillWavyBand(image, 70, 5, 0.012, rgba(210, 220, 230), 90, phase: 1.0);
  fillWavyBand(image, 75, 4, 0.018, rgba(200, 210, 225), 95, phase: 2.5);

  // Mid-ground snow
  fillGradientRect(image, 0, 85, W - 1, H - 1, rgba(220, 230, 240), rgba(200, 210, 225));

  // Snow-covered ground with blue-white shadows
  for (int i = 0; i < 40; i++) {
    final sx = _rng.nextInt(W);
    final sy = 100 + _rng.nextInt(75);
    setPixel(image, sx, sy, rgba(185, 200, 215)); // shadow spots
  }

  // Snowdrifts (overlapping white mounds)
  fillEllipse(image, 50, 120, 30, 8, rgba(235, 240, 248));
  fillEllipse(image, 140, 125, 25, 6, rgba(230, 235, 245));
  fillEllipse(image, 230, 118, 35, 9, rgba(238, 242, 250));
  fillEllipse(image, 300, 130, 20, 5, rgba(232, 237, 246));

  // Drift shadow undersides
  fillEllipse(image, 50, 126, 28, 3, rgba(190, 200, 215));
  fillEllipse(image, 140, 130, 23, 3, rgba(185, 195, 210));
  fillEllipse(image, 230, 125, 33, 3, rgba(192, 202, 218));

  // Bare/frosted trees
  void drawFrostedTree(int tx, int baseY) {
    final trunkColor = rgba(70, 55, 40);
    // Trunk
    for (int y = baseY; y > baseY - 40; y--) {
      final w = max(1, 2 - (baseY - y) ~/ 20);
      for (int dx = -w; dx <= w; dx++) {
        setPixel(image, tx + dx, y, trunkColor);
      }
    }
    // Bare branches with frost
    for (int b = 0; b < 4; b++) {
      final bY = baseY - 15 - _rng.nextInt(22);
      final dir = b.isEven ? 1 : -1;
      for (int i = 0; i < 10 + _rng.nextInt(8); i++) {
        final bx = tx + dir * i;
        final by = bY - i ~/ 3;
        setPixel(image, bx, by, trunkColor);
        // White frost on branch
        setPixel(image, bx, by - 1, rgba(230, 235, 245, 180));
      }
    }
  }

  drawFrostedTree(70, 115);
  drawFrostedTree(190, 110);
  drawFrostedTree(290, 120);

  // Sparkle effects (occasional bright white pixels)
  for (int i = 0; i < 30; i++) {
    final sx = _rng.nextInt(W);
    final sy = _rng.nextInt(H);
    setPixel(image, sx, sy, rgba(255, 255, 255));
  }

  // Falling snow (small white dots scattered)
  for (int i = 0; i < 50; i++) {
    final sx = _rng.nextInt(W);
    final sy = _rng.nextInt(H - 20);
    setPixel(image, sx, sy, rgba(255, 255, 255, 200));
  }

  return image;
}

// ── 9. Castle ────────────────────────────────────────────────────────
img.Image generateCastle() {
  final image = img.Image(width: W, height: H);

  // Dark stone ceiling
  fillGradientRect(image, 0, 0, W - 1, 25, rgba(40, 38, 35), rgba(55, 52, 48));

  // Stone walls
  fillGradientRect(image, 0, 25, W - 1, H - 1, rgba(65, 62, 58), rgba(55, 52, 48));

  // Stone block texture on walls
  for (int row = 0; row < H; row += 12) {
    // Horizontal mortar lines
    for (int x = 0; x < W; x++) {
      setPixel(image, x, row, rgba(45, 42, 38));
    }
    // Vertical mortar lines (offset every other row)
    final offset = (row ~/ 12).isEven ? 0 : 20;
    for (int x = offset; x < W; x += 40) {
      for (int dy = 0; dy < 12 && row + dy < H; dy++) {
        setPixel(image, x, row + dy, rgba(45, 42, 38));
      }
    }
  }

  // Gothic arched windows (3 windows)
  void drawGothicWindow(int cx, int topY, int width, int height) {
    // Window opening (dark with faint light)
    for (int y = topY; y < topY + height; y++) {
      final halfW = width ~/ 2;
      // Arch at top
      if (y < topY + width ~/ 2) {
        final archDist = y - topY;
        final aw = (sqrt(max(0, halfW * halfW - (halfW - archDist) * (halfW - archDist)))).round();
        for (int dx = -aw; dx <= aw; dx++) {
          // Faint moonlight gradient
          final lightAlpha = 80 - (y - topY) * 2;
          blendPixel(image, cx + dx, y, rgba(60, 70, 100, lightAlpha.clamp(20, 80)));
          setPixel(image, cx + dx, y, rgba(25, 30, 45));
        }
      } else {
        for (int dx = -halfW; dx <= halfW; dx++) {
          setPixel(image, cx + dx, y, rgba(25, 30, 45));
        }
      }
    }
    // Faint light glow from window
    for (int dy = -5; dy <= height + 5; dy++) {
      for (int dx = -(width ~/ 2 + 5); dx <= width ~/ 2 + 5; dx++) {
        final dist = sqrt(dx * dx + (dy - height / 2) * (dy - height / 2));
        if (dist < width + 5) {
          final a = (20 * (1 - dist / (width + 5))).round().clamp(0, 255);
          blendPixel(image, cx + dx, topY + dy, rgba(80, 100, 150, a));
        }
      }
    }
    // Stone frame
    for (int y = topY; y < topY + height; y++) {
      setPixel(image, cx - width ~/ 2 - 1, y, rgba(80, 75, 70));
      setPixel(image, cx + width ~/ 2 + 1, y, rgba(80, 75, 70));
    }
  }

  drawGothicWindow(80, 30, 12, 45);
  drawGothicWindow(160, 25, 14, 50);
  drawGothicWindow(240, 30, 12, 45);

  // Stone floor
  fillGradientRect(image, 0, 135, W - 1, H - 1, rgba(60, 57, 52), rgba(50, 48, 44));

  // Red carpet strip down the middle
  fillRect(image, 120, 135, 200, H - 1, rgba(120, 25, 25));
  fillRect(image, 122, 135, 198, H - 1, rgba(140, 30, 30));
  // Carpet pattern
  for (int y = 140; y < H; y += 8) {
    fillRect(image, 125, y, 195, y + 1, rgba(160, 45, 35));
  }
  // Carpet edge gold trim
  for (int y = 135; y < H; y++) {
    setPixel(image, 120, y, rgba(180, 150, 50));
    setPixel(image, 200, y, rgba(180, 150, 50));
  }

  // Torches on walls
  void drawWallTorch(int tx, int ty) {
    // Bracket
    fillRect(image, tx - 1, ty, tx + 1, ty + 6, rgba(120, 90, 40));
    // Flame
    fillEllipse(image, tx, ty - 2, 2, 3, rgba(255, 160, 40));
    setPixel(image, tx, ty - 4, rgba(255, 220, 80));
    setPixel(image, tx - 1, ty - 3, rgba(255, 180, 50));
    setPixel(image, tx + 1, ty - 3, rgba(255, 180, 50));
    // Glow
    addHighlight(image, tx, ty - 2, 20, 50);
  }

  drawWallTorch(40, 55);
  drawWallTorch(130, 50);
  drawWallTorch(195, 50);
  drawWallTorch(280, 55);

  // Banners/flags on walls
  void drawBanner(int bx, int topY, img.ColorRgba8 bannerColor) {
    for (int y = topY; y < topY + 30; y++) {
      final w = 5 - (y - topY) ~/ 10;
      for (int dx = -w; dx <= w; dx++) {
        setPixel(image, bx + dx, y, bannerColor);
      }
    }
    // Banner rod
    fillRect(image, bx - 6, topY - 1, bx + 6, topY, rgba(140, 120, 50));
  }

  drawBanner(55, 35, rgba(140, 30, 30));
  drawBanner(265, 35, rgba(30, 40, 130));

  return image;
}

// ── 10. Beach ────────────────────────────────────────────────────────
img.Image generateBeach() {
  final image = img.Image(width: W, height: H);

  // Blue sky
  fillGradientRect(image, 0, 0, W - 1, 60, rgba(80, 140, 220), rgba(140, 190, 240));

  // White clouds
  fillEllipse(image, 70, 20, 20, 7, rgba(255, 255, 255, 150));
  fillEllipse(image, 85, 17, 14, 5, rgba(255, 255, 255, 130));
  fillEllipse(image, 55, 22, 12, 4, rgba(255, 255, 255, 110));

  fillEllipse(image, 220, 30, 18, 6, rgba(255, 255, 255, 140));
  fillEllipse(image, 235, 27, 12, 5, rgba(255, 255, 255, 120));

  // Ocean (blue-teal gradient)
  fillGradientRect(image, 0, 55, W - 1, 105, rgba(30, 90, 150), rgba(50, 140, 170));

  // Wave details on ocean (horizontal white lines)
  for (int waveY = 60; waveY < 100; waveY += 8) {
    for (int x = 0; x < W; x++) {
      final waveOffset = (sin(x * 0.08 + waveY * 0.5) * 2).round();
      blendPixel(image, x, waveY + waveOffset, rgba(255, 255, 255, 30 + _rng.nextInt(20)));
    }
  }

  // Shoreline foam
  for (int x = 0; x < W; x++) {
    final foamY = 103 + (sin(x * 0.05) * 2).round();
    setPixel(image, x, foamY, rgba(220, 235, 245));
    setPixel(image, x, foamY + 1, rgba(200, 220, 235, 180));
    if (_rng.nextInt(3) == 0) {
      setPixel(image, x, foamY - 1, rgba(240, 248, 255, 150));
    }
  }

  // Wet sand (darker, near water)
  fillGradientRect(image, 0, 105, W - 1, 115, rgba(180, 160, 120), rgba(200, 180, 140));

  // Dry sand
  fillGradientRect(image, 0, 115, W - 1, H - 1, rgba(220, 200, 150), rgba(210, 190, 140));

  // Sand texture
  for (int i = 0; i < 60; i++) {
    final sx = _rng.nextInt(W);
    final sy = 110 + _rng.nextInt(65);
    setPixel(image, sx, sy, rgba(230, 210, 165));
  }

  // Palm tree left
  void drawPalmTree(int tx, int baseY) {
    // Trunk (curved brown)
    for (int y = baseY; y > baseY - 55; y--) {
      final curve = (sin((baseY - y) * 0.03) * 6).round();
      for (int dx = -2; dx <= 2; dx++) {
        final shade = dx < 0 ? rgba(140, 110, 60) : rgba(100, 75, 40);
        setPixel(image, tx + curve + dx, y, shade);
      }
      // Bark rings
      if ((baseY - y) % 5 == 0) {
        for (int dx = -2; dx <= 2; dx++) {
          setPixel(image, tx + curve + dx, y, rgba(90, 65, 35));
        }
      }
    }
    // Fronds (palm leaves)
    final topX = tx + (sin((55) * 0.03) * 6).round();
    final topY = baseY - 55;
    for (int f = 0; f < 5; f++) {
      final angle = -0.8 + f * 0.4;
      for (int i = 0; i < 20; i++) {
        final fx = topX + (cos(angle) * i).round();
        final fy = topY + (sin(angle) * i).round() + (i * i * 0.02).round();
        final leafGreen = rgba(40, 120 + _rng.nextInt(30), 30);
        setPixel(image, fx, fy, leafGreen);
        setPixel(image, fx, fy + 1, leafGreen);
        if (i > 5) setPixel(image, fx, fy + 2, rgba(35, 100, 25));
      }
    }
  }

  drawPalmTree(40, 140);
  drawPalmTree(290, 145);

  // Rocks at right edge
  fillShaded16Ellipse(image, 305, 135, 8, 5, rgba(120, 110, 100));
  fillShaded16Ellipse(image, 298, 138, 5, 3, rgba(110, 100, 90));

  // Shells/details on sand
  for (int i = 0; i < 8; i++) {
    final sx = 60 + _rng.nextInt(200);
    final sy = 120 + _rng.nextInt(50);
    setPixel(image, sx, sy, rgba(240, 220, 190));
    setPixel(image, sx + 1, sy, rgba(230, 210, 180));
  }

  // Sun reflection on water
  for (int y = 55; y < 100; y++) {
    final sparkleX = 250 + _rng.nextInt(20) - 10;
    blendPixel(image, sparkleX, y, rgba(255, 255, 220, 20 + _rng.nextInt(15)));
  }

  // Sun in sky
  addHighlight(image, 260, 15, 10, 80);

  return image;
}

// ── Main ─────────────────────────────────────────────────────────────
void main() {
  Directory('assets/sprites/backgrounds').createSync(recursive: true);

  print('Generating 16-bit style backgrounds (320×180)...');

  print('\n1/10 Meadow');
  saveBg(generateMeadow(), 'meadow');

  print('2/10 Forest');
  saveBg(generateForest(), 'forest');

  print('3/10 Swamp');
  saveBg(generateSwamp(), 'swamp');

  print('4/10 Desert');
  saveBg(generateDesert(), 'desert');

  print('5/10 Ruins');
  saveBg(generateRuins(), 'ruins');

  print('6/10 Mountain');
  saveBg(generateMountain(), 'mountain');

  print('7/10 Cave');
  saveBg(generateCave(), 'cave');

  print('8/10 Snow');
  saveBg(generateSnow(), 'snow');

  print('9/10 Castle');
  saveBg(generateCastle(), 'castle');

  print('10/10 Beach');
  saveBg(generateBeach(), 'beach');

  print('\nDone! All 10 backgrounds generated.');
}
