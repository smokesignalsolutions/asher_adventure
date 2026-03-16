import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 32, height: 32, numChannels: 4);

  final black = img.ColorRgba8(20, 20, 30, 255);
  final red = img.ColorRgba8(200, 40, 40, 255);
  final darkRed = img.ColorRgba8(140, 20, 20, 255);
  final redGlow = img.ColorRgba8(255, 60, 40, 100);

  void setPixel(int x, int y, img.ColorRgba8 c) {
    if (x >= 0 && x < 32 && y >= 0 && y < 32) {
      image.setPixelRgba(x, y, c.r.toInt(), c.g.toInt(), c.b.toInt(), c.a.toInt());
    }
  }

  void blendPixel(int x, int y, img.ColorRgba8 c) {
    if (x < 0 || x >= 32 || y < 0 || y >= 32) return;
    final a = c.a.toInt() / 255.0;
    final existing = image.getPixel(x, y);
    final nr = (c.r.toInt() * a + existing.r.toInt() * (1 - a)).round().clamp(0, 255);
    final ng = (c.g.toInt() * a + existing.g.toInt() * (1 - a)).round().clamp(0, 255);
    final nb = (c.b.toInt() * a + existing.b.toInt() * (1 - a)).round().clamp(0, 255);
    final na = (c.a.toInt() + existing.a.toInt() * (1 - a)).round().clamp(0, 255);
    image.setPixelRgba(x, y, nr, ng, nb, na);
  }

  // Lightning bolt — classic zigzag shape
  final boltPixels = <(int, int)>[
    // Top cap
    (13, 2), (14, 2), (15, 2),
    (12, 3), (13, 3), (14, 3), (15, 3), (16, 3),
    // Zig down-left
    (14, 4), (15, 4), (16, 4),
    (13, 5), (14, 5), (15, 5),
    (12, 6), (13, 6), (14, 6),
    (11, 7), (12, 7), (13, 7),
    (10, 8), (11, 8), (12, 8),
    (9, 9), (10, 9), (11, 9),
    // Flat bar going right
    (10, 10), (11, 10), (12, 10), (13, 10), (14, 10), (15, 10), (16, 10), (17, 10), (18, 10), (19, 10),
    (10, 11), (11, 11), (12, 11), (13, 11), (14, 11), (15, 11), (16, 11), (17, 11), (18, 11), (19, 11),
    // Zag down-left
    (18, 12), (19, 12), (20, 12),
    (17, 13), (18, 13), (19, 13),
    (16, 14), (17, 14), (18, 14),
    (15, 15), (16, 15), (17, 15),
    (14, 16), (15, 16), (16, 16),
    (13, 17), (14, 17), (15, 17),
    // Flat bar going right
    (10, 18), (11, 18), (12, 18), (13, 18), (14, 18), (15, 18), (16, 18), (17, 18), (18, 18), (19, 18), (20, 18),
    (10, 19), (11, 19), (12, 19), (13, 19), (14, 19), (15, 19), (16, 19), (17, 19), (18, 19), (19, 19), (20, 19),
    // Final point down
    (19, 20), (20, 20), (21, 20),
    (18, 21), (19, 21), (20, 21),
    (17, 22), (18, 22), (19, 22),
    (16, 23), (17, 23), (18, 23),
    (15, 24), (16, 24), (17, 24),
    (14, 25), (15, 25), (16, 25),
    (15, 26), (16, 26),
    (16, 27),
  ];

  // Red glow around bolt
  for (final (px, py) in boltPixels) {
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        blendPixel(px + dx, py + dy, redGlow);
      }
    }
  }

  // Main bolt body — black
  for (final (px, py) in boltPixels) {
    setPixel(px, py, black);
  }

  // Red accent highlights — left/top edges
  final redAccents = <(int, int)>[
    (12, 3), (13, 2),
    (9, 9), (10, 8), (11, 7),
    (10, 10), (11, 10), (12, 10),
    (10, 18), (11, 18), (12, 18),
    (14, 25), (15, 26),
    (13, 5), (12, 6), (11, 7),
    (17, 13), (16, 14), (15, 15),
    (18, 21), (17, 22), (16, 23),
  ];

  for (final (px, py) in redAccents) {
    setPixel(px, py, red);
  }

  // Dark red on right/bottom edges for depth
  final darkRedAccents = <(int, int)>[
    (16, 3), (16, 4),
    (19, 10), (19, 11),
    (20, 12), (19, 12),
    (20, 18), (20, 19), (21, 20),
    (16, 27),
  ];

  for (final (px, py) in darkRedAccents) {
    setPixel(px, py, darkRed);
  }

  File('assets/sprites/abilities/lightning.png').writeAsBytesSync(img.encodePng(image));
  print('Lightning icon generated.');
}
