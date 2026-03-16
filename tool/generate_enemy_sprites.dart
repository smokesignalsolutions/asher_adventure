import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'sprite_helpers.dart';

// ── Enemy-specific palette ──────────────────────────────────────────────

final goblinGreen = rgba(80, 160, 60);
final goblinDark = rgba(50, 110, 35);
final orcGreen = rgba(90, 140, 60);
final orcDark = rgba(60, 100, 40);
final wolfGray = rgba(140, 140, 150);
final wolfDark = rgba(100, 100, 110);
final boneWhite = rgba(225, 220, 200);
final boneShadow = rgba(190, 180, 160);
final banditBrown = rgba(100, 75, 50);
final banditDark = rgba(70, 50, 30);
final spiderBlack = rgba(50, 40, 35);
final spiderDark = rgba(30, 25, 20);
final ogreBrown = rgba(140, 130, 80);
final ogreDark = rgba(100, 90, 55);
final harpyTan = rgba(210, 185, 150);
final harpyDark = rgba(170, 145, 110);
final trollGreen = rgba(70, 140, 70);
final trollDark = rgba(45, 100, 45);
final wraithBlue = rgba(60, 60, 100);
final wraithGlow = rgba(100, 100, 200, 120);
final minotaurBrown = rgba(120, 80, 50);
final minotaurDark = rgba(85, 55, 30);
final wyvernGreen = rgba(80, 120, 70);
final wyvernDark = rgba(55, 85, 45);
final lichPurple = rgba(100, 50, 130);
final lichDark = rgba(70, 30, 95);
final golemGray = rgba(150, 150, 160);
final golemDark = rgba(110, 110, 120);
final vampireBlack = rgba(40, 35, 50);
final vampireDark = rgba(25, 20, 35);
final vampireSkin = rgba(220, 210, 220);
final chimeraGold = rgba(180, 150, 60);
final chimeraDark = rgba(130, 105, 35);
final dkArmor = rgba(60, 55, 70);
final dkDark = rgba(35, 30, 45);
final dragonRed = rgba(160, 50, 40);
final dragonDark = rgba(110, 30, 25);
final demonRed = rgba(180, 40, 30);
final demonDark = rgba(130, 25, 15);
final titanGray = rgba(160, 155, 145);
final titanDark = rgba(120, 115, 105);
final shadowDark = rgba(30, 20, 40);
final shadowPurple = rgba(80, 40, 120);
final wyrmTeal = rgba(50, 120, 110);
final wyrmDark = rgba(30, 80, 75);
final voidBlack = rgba(25, 15, 35);
final voidPurple = rgba(100, 40, 160);

// ── Regular enemies ─────────────────────────────────────────────────────

img.Image drawGoblin() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Legs
  drawShadedLine(image, 27, 48, 27, 56, 4, goblinDark);
  drawShadedLine(image, 37, 48, 37, 56, 4, goblinDark);
  // Feet
  fillShaded16Ellipse(image, 27, 57, 4, 2, goblinDark);
  fillShaded16Ellipse(image, 37, 57, 4, 2, goblinDark);

  // Body — small and hunched
  fillShaded16Ellipse(image, 32, 40, 9, 10, goblinGreen);

  // Arms
  drawShadedLine(image, 22, 36, 18, 44, 3, goblinGreen);
  drawShadedLine(image, 42, 36, 46, 44, 3, goblinGreen);

  // Dagger in right hand
  drawThickLine(image, 47, 44, 50, 34, 2, rgba(180, 180, 190));
  fillCircle(image, 50, 33, 1, rgba(220, 220, 230));

  // Head — big for a small creature
  fillShaded16Circle(image, 32, 24, 10, goblinGreen);

  // Pointy ears
  fillTriangle(image, 19, 22, 22, 18, 22, 26, goblinGreen);
  fillTriangle(image, 45, 22, 42, 18, 42, 26, goblinGreen);

  // Eyes — big and yellow
  fillShaded16Ellipse(image, 27, 22, 3, 3, rgba(240, 230, 60));
  fillShaded16Ellipse(image, 37, 22, 3, 3, rgba(240, 230, 60));
  addHighlight(image, 26, 21, 1);
  addHighlight(image, 36, 21, 1);
  // Pupils
  fillCircle(image, 28, 23, 1, rgba(20, 20, 20));
  fillCircle(image, 38, 23, 1, rgba(20, 20, 20));

  // Mouth — toothy grin
  fillRect(image, 28, 28, 36, 29, rgba(40, 20, 20));
  fillRect(image, 30, 28, 30, 28, boneWhite);
  fillRect(image, 34, 28, 34, 28, boneWhite);

  return image;
}

img.Image drawWolf() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Facing left — tail on right
  // Tail
  drawShadedLine(image, 55, 28, 60, 20, 3, wolfGray);

  // Back legs
  drawShadedLine(image, 48, 38, 48, 50, 4, wolfDark);
  drawShadedLine(image, 44, 38, 44, 50, 4, wolfDark);
  // Front legs
  drawShadedLine(image, 20, 38, 20, 50, 4, wolfDark);
  drawShadedLine(image, 16, 38, 16, 50, 4, wolfDark);
  // Paws
  fillShaded16Ellipse(image, 48, 52, 3, 2, wolfDark);
  fillShaded16Ellipse(image, 44, 52, 3, 2, wolfDark);
  fillShaded16Ellipse(image, 20, 52, 3, 2, wolfDark);
  fillShaded16Ellipse(image, 16, 52, 3, 2, wolfDark);

  // Body — long horizontal ellipse
  fillShaded16Ellipse(image, 32, 34, 18, 9, wolfGray);

  // Chest tuft — lighter
  fillShaded16Ellipse(image, 18, 36, 5, 6, rgba(180, 180, 190));

  // Head
  fillShaded16Ellipse(image, 10, 26, 8, 7, wolfGray);
  // Snout
  fillShaded16Ellipse(image, 4, 29, 5, 3, rgba(160, 160, 170));
  // Nose
  fillCircle(image, 1, 28, 2, rgba(30, 30, 30));
  addHighlight(image, 0, 27, 1);

  // Ears — pointed
  fillTriangle(image, 6, 20, 9, 14, 12, 20, wolfDark);
  fillTriangle(image, 12, 20, 15, 14, 18, 20, wolfDark);
  // Inner ear
  fillTriangle(image, 8, 20, 9, 16, 11, 20, rgba(180, 130, 130));
  fillTriangle(image, 13, 20, 15, 16, 17, 20, rgba(180, 130, 130));

  // Eye — fierce
  fillShaded16Ellipse(image, 8, 25, 2, 2, rgba(230, 200, 50));
  addHighlight(image, 7, 24, 1);
  fillCircle(image, 9, 25, 1, rgba(20, 20, 20));

  // Mouth / fangs
  drawThickLine(image, 2, 31, 8, 32, 1, rgba(40, 30, 30));
  fillRect(image, 3, 31, 3, 33, boneWhite);
  fillRect(image, 6, 31, 6, 33, boneWhite);

  return image;
}

img.Image drawBandit() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Sword in right hand
  drawThickLine(image, 48, 42, 48, 22, 2, rgba(190, 195, 205));
  fillRect(image, 46, 42, 50, 44, woodBrown);
  fillTriangle(image, 47, 22, 49, 22, 48, 18, rgba(200, 205, 215));
  addHighlight(image, 48, 28, 1);

  // Legs
  drawShadedLine(image, 27, 48, 27, 56, 4, banditDark);
  drawShadedLine(image, 37, 48, 37, 56, 4, banditDark);
  fillShaded16Ellipse(image, 27, 57, 5, 2, rgba(60, 40, 25));
  fillShaded16Ellipse(image, 37, 57, 5, 2, rgba(60, 40, 25));

  // Body
  fillShaded16Ellipse(image, 32, 38, 10, 12, banditBrown);
  // Belt
  fillRect(image, 22, 42, 42, 44, rgba(50, 35, 20));
  fillCircle(image, 32, 43, 2, rgba(180, 160, 50));

  // Arms
  drawShadedLine(image, 20, 33, 17, 42, 4, banditBrown);
  drawShadedLine(image, 44, 33, 47, 42, 4, banditBrown);
  fillShaded16Circle(image, 17, 43, 3, skin);
  fillShaded16Circle(image, 47, 43, 3, skin);

  // Head
  fillShaded16Circle(image, 32, 18, 9, skin);
  // Bandana/mask
  fillRect(image, 23, 18, 41, 22, rgba(80, 30, 30));
  // Eyes peeking over mask
  fillRect(image, 27, 16, 29, 17, rgba(30, 30, 30));
  fillRect(image, 35, 16, 37, 17, rgba(30, 30, 30));

  return image;
}

img.Image drawSkeleton() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Sword
  drawThickLine(image, 48, 42, 48, 22, 2, rgba(180, 180, 190));
  fillRect(image, 46, 42, 50, 44, rgba(100, 90, 80));
  fillTriangle(image, 47, 22, 49, 22, 48, 18, rgba(190, 190, 200));

  // Leg bones
  drawThickLine(image, 27, 46, 27, 56, 3, boneWhite);
  drawThickLine(image, 37, 46, 37, 56, 3, boneWhite);
  fillShaded16Ellipse(image, 27, 57, 4, 2, boneShadow);
  fillShaded16Ellipse(image, 37, 57, 4, 2, boneShadow);

  // Ribcage
  fillShaded16Ellipse(image, 32, 38, 9, 10, boneWhite);
  // Rib lines (darker)
  for (int i = 0; i < 4; i++) {
    fillRect(image, 24, 32 + i * 3, 40, 32 + i * 3, boneShadow);
  }
  // Dark center (hollow)
  fillEllipse(image, 32, 38, 5, 7, rgba(30, 25, 25));

  // Arms — bony
  drawThickLine(image, 22, 32, 17, 42, 3, boneWhite);
  drawThickLine(image, 42, 32, 47, 42, 3, boneWhite);
  fillShaded16Circle(image, 17, 43, 2, boneShadow);
  fillShaded16Circle(image, 47, 43, 2, boneShadow);

  // Skull
  fillShaded16Circle(image, 32, 18, 9, boneWhite);
  // Eye sockets — dark and hollow
  fillCircle(image, 28, 17, 3, rgba(20, 15, 15));
  fillCircle(image, 36, 17, 3, rgba(20, 15, 15));
  // Glowing eyes
  fillCircle(image, 28, 17, 1, rgba(200, 50, 50));
  fillCircle(image, 36, 17, 1, rgba(200, 50, 50));
  addHighlight(image, 27, 16, 1, 100);
  addHighlight(image, 35, 16, 1, 100);
  // Nose hole
  fillTriangle(image, 31, 20, 33, 20, 32, 22, rgba(30, 25, 25));
  // Teeth
  fillRect(image, 28, 24, 36, 25, boneWhite);
  fillRect(image, 29, 24, 29, 25, rgba(30, 25, 25));
  fillRect(image, 31, 24, 31, 25, rgba(30, 25, 25));
  fillRect(image, 33, 24, 33, 25, rgba(30, 25, 25));
  fillRect(image, 35, 24, 35, 25, rgba(30, 25, 25));

  return image;
}

img.Image drawOrcGrunt() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Club in right hand
  drawThickLine(image, 50, 44, 52, 22, 3, woodBrown);
  fillShaded16Ellipse(image, 53, 20, 4, 5, rgba(100, 80, 50));

  // Legs — stocky
  drawShadedLine(image, 26, 48, 26, 58, 5, orcDark);
  drawShadedLine(image, 38, 48, 38, 58, 5, orcDark);
  fillShaded16Ellipse(image, 26, 59, 5, 2, orcDark);
  fillShaded16Ellipse(image, 38, 59, 5, 2, orcDark);

  // Body — muscular
  fillShaded16Ellipse(image, 32, 38, 12, 12, orcGreen);
  // Chest
  fillShaded16Ellipse(image, 30, 34, 6, 5, rgba(100, 155, 70));

  // Arms — thick
  drawShadedLine(image, 19, 33, 15, 44, 5, orcGreen);
  drawShadedLine(image, 45, 33, 49, 44, 5, orcGreen);
  fillShaded16Circle(image, 15, 45, 3, orcDark);
  fillShaded16Circle(image, 49, 45, 3, orcDark);

  // Head
  fillShaded16Circle(image, 32, 20, 10, orcGreen);
  // Brow ridge
  fillRect(image, 24, 16, 40, 18, orcDark);
  // Eyes — angry
  fillShaded16Ellipse(image, 27, 19, 3, 2, rgba(220, 200, 50));
  fillShaded16Ellipse(image, 37, 19, 3, 2, rgba(220, 200, 50));
  fillCircle(image, 28, 19, 1, rgba(20, 20, 20));
  fillCircle(image, 38, 19, 1, rgba(20, 20, 20));
  addHighlight(image, 26, 18, 1);
  addHighlight(image, 36, 18, 1);

  // Jaw + tusks
  fillShaded16Ellipse(image, 32, 26, 6, 3, orcDark);
  fillTriangle(image, 27, 24, 28, 24, 27, 21, boneWhite);
  fillTriangle(image, 37, 24, 36, 24, 37, 21, boneWhite);

  return image;
}

img.Image drawGiantSpider() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Facing left
  // Legs — 8 total, 4 per side, arching from body
  final legColor = rgba(60, 50, 45);
  // Right side legs (upper)
  drawShadedLine(image, 38, 30, 55, 18, 2, legColor);
  drawShadedLine(image, 55, 18, 58, 30, 2, legColor);
  drawShadedLine(image, 38, 34, 54, 24, 2, legColor);
  drawShadedLine(image, 54, 24, 56, 36, 2, legColor);
  drawShadedLine(image, 38, 38, 52, 34, 2, legColor);
  drawShadedLine(image, 52, 34, 55, 46, 2, legColor);
  drawShadedLine(image, 36, 42, 48, 44, 2, legColor);
  drawShadedLine(image, 48, 44, 52, 54, 2, legColor);

  // Left side legs (lower/front)
  drawShadedLine(image, 24, 30, 8, 18, 2, legColor);
  drawShadedLine(image, 8, 18, 4, 30, 2, legColor);
  drawShadedLine(image, 24, 34, 10, 24, 2, legColor);
  drawShadedLine(image, 10, 24, 6, 36, 2, legColor);
  drawShadedLine(image, 24, 38, 12, 34, 2, legColor);
  drawShadedLine(image, 12, 34, 8, 46, 2, legColor);
  drawShadedLine(image, 26, 42, 16, 44, 2, legColor);
  drawShadedLine(image, 16, 44, 10, 54, 2, legColor);

  // Abdomen (back, larger)
  fillShaded16Ellipse(image, 40, 36, 10, 8, spiderBlack);
  // Markings on abdomen
  fillShaded16Ellipse(image, 40, 34, 4, 2, rgba(140, 40, 30));
  fillShaded16Ellipse(image, 40, 38, 3, 2, rgba(140, 40, 30));

  // Thorax (front, smaller)
  fillShaded16Ellipse(image, 26, 34, 7, 6, spiderBlack);

  // Head
  fillShaded16Circle(image, 18, 30, 6, spiderBlack);

  // Eyes — 8 red eyes, 2 large + 6 small
  fillShaded16Circle(image, 15, 28, 2, rgba(200, 30, 20));
  fillShaded16Circle(image, 21, 28, 2, rgba(200, 30, 20));
  addHighlight(image, 14, 27, 1);
  addHighlight(image, 20, 27, 1);
  // Smaller eyes
  fillCircle(image, 13, 30, 1, rgba(180, 25, 15));
  fillCircle(image, 23, 30, 1, rgba(180, 25, 15));
  fillCircle(image, 14, 32, 1, rgba(180, 25, 15));
  fillCircle(image, 22, 32, 1, rgba(180, 25, 15));
  fillCircle(image, 16, 26, 1, rgba(180, 25, 15));
  fillCircle(image, 20, 26, 1, rgba(180, 25, 15));

  // Fangs
  drawThickLine(image, 15, 34, 13, 40, 2, boneWhite);
  drawThickLine(image, 21, 34, 23, 40, 2, boneWhite);

  return image;
}

img.Image drawDarkMage() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final robeColor = rgba(30, 30, 60);
  final robeDark = rgba(18, 18, 40);

  // Magic orb floating in right hand
  fillCircle(image, 48, 32, 6, rgba(80, 40, 180, 60));
  fillShaded16Circle(image, 48, 32, 4, rgba(120, 60, 220));
  addHighlight(image, 46, 30, 2);
  // Orb sparkles
  setPixel(image, 44, 28, rgba(200, 180, 255));
  setPixel(image, 52, 30, rgba(200, 180, 255));
  setPixel(image, 46, 36, rgba(200, 180, 255));

  // Robe / legs area — long flowing robe
  fillShaded16Ellipse(image, 32, 50, 10, 8, robeColor);

  // Body
  fillShaded16Ellipse(image, 32, 38, 10, 12, robeColor);
  // Belt with gem
  fillRect(image, 22, 40, 42, 42, rgba(60, 50, 80));
  fillShaded16Circle(image, 32, 41, 2, rgba(160, 60, 220));
  addHighlight(image, 31, 40, 1);

  // Arms
  drawShadedLine(image, 21, 34, 16, 42, 4, robeColor);
  drawShadedLine(image, 43, 34, 47, 38, 4, robeColor);

  // Hood
  fillShaded16Circle(image, 32, 16, 11, robeDark);
  // Face in shadow — only eyes visible
  fillEllipse(image, 32, 19, 6, 5, rgba(10, 10, 20));
  // Glowing eyes
  fillCircle(image, 28, 18, 2, rgba(180, 80, 255));
  fillCircle(image, 36, 18, 2, rgba(180, 80, 255));
  addHighlight(image, 27, 17, 1, 200);
  addHighlight(image, 35, 17, 1, 200);

  return image;
}

img.Image drawOgre() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Big club
  drawThickLine(image, 52, 46, 56, 18, 4, rgba(100, 75, 45));
  fillShaded16Ellipse(image, 57, 16, 5, 6, rgba(90, 70, 40));
  // Nails in club
  setPixel(image, 55, 13, rgba(180, 180, 180));
  setPixel(image, 59, 18, rgba(180, 180, 180));

  // Legs — very thick
  drawShadedLine(image, 24, 48, 24, 58, 6, ogreDark);
  drawShadedLine(image, 40, 48, 40, 58, 6, ogreDark);
  fillShaded16Ellipse(image, 24, 60, 6, 3, ogreDark);
  fillShaded16Ellipse(image, 40, 60, 6, 3, ogreDark);

  // Body — fat belly
  fillShaded16Ellipse(image, 32, 38, 14, 14, ogreBrown);
  // Belly
  fillShaded16Ellipse(image, 32, 42, 10, 8, rgba(160, 150, 100));

  // Arms — thick and long
  drawShadedLine(image, 16, 32, 12, 46, 5, ogreBrown);
  drawShadedLine(image, 48, 32, 52, 46, 5, ogreBrown);
  fillShaded16Circle(image, 12, 47, 4, ogreDark);
  fillShaded16Circle(image, 52, 47, 4, ogreDark);

  // Head — small relative to body
  fillShaded16Circle(image, 32, 18, 8, ogreBrown);
  // Brow
  fillRect(image, 25, 14, 39, 16, ogreDark);
  // Eyes — small and mean
  fillCircle(image, 28, 17, 2, rgba(220, 200, 50));
  fillCircle(image, 36, 17, 2, rgba(220, 200, 50));
  fillCircle(image, 29, 17, 1, rgba(20, 20, 20));
  fillCircle(image, 37, 17, 1, rgba(20, 20, 20));
  // Underbite
  fillShaded16Ellipse(image, 32, 24, 5, 3, ogreDark);
  fillRect(image, 28, 22, 28, 23, boneWhite);
  fillRect(image, 36, 22, 36, 23, boneWhite);

  return image;
}

img.Image drawHarpy() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final wingColor = rgba(140, 100, 70);
  final wingDark = rgba(100, 70, 45);
  final featherColor = rgba(170, 130, 90);

  // Left wing
  fillTriangle(image, 8, 20, 2, 10, 20, 30, wingColor);
  fillTriangle(image, 5, 14, 2, 10, 15, 24, wingDark);
  // Feather tips
  fillTriangle(image, 2, 10, 0, 6, 5, 12, featherColor);
  fillTriangle(image, 4, 8, 2, 4, 8, 10, featherColor);

  // Right wing
  fillTriangle(image, 56, 20, 62, 10, 44, 30, wingColor);
  fillTriangle(image, 59, 14, 62, 10, 49, 24, wingDark);
  fillTriangle(image, 62, 10, 63, 6, 59, 12, featherColor);
  fillTriangle(image, 60, 8, 62, 4, 56, 10, featherColor);

  // Talons / legs
  drawShadedLine(image, 28, 50, 26, 58, 2, rgba(160, 140, 50));
  drawShadedLine(image, 36, 50, 38, 58, 2, rgba(160, 140, 50));
  // Claw toes
  drawThickLine(image, 26, 58, 22, 60, 1, rgba(160, 140, 50));
  drawThickLine(image, 26, 58, 28, 61, 1, rgba(160, 140, 50));
  drawThickLine(image, 38, 58, 34, 60, 1, rgba(160, 140, 50));
  drawThickLine(image, 38, 58, 40, 61, 1, rgba(160, 140, 50));

  // Body
  fillShaded16Ellipse(image, 32, 40, 9, 12, harpyTan);

  // Feathered chest
  fillShaded16Ellipse(image, 32, 36, 6, 5, featherColor);

  // Head
  fillShaded16Circle(image, 32, 20, 8, harpyTan);
  // Hair — wild feathered
  fillTriangle(image, 24, 14, 28, 8, 32, 14, wingColor);
  fillTriangle(image, 30, 12, 33, 6, 36, 12, wingColor);
  fillTriangle(image, 34, 14, 38, 8, 40, 14, wingColor);

  // Eyes — fierce
  fillShaded16Ellipse(image, 28, 19, 2, 2, rgba(220, 180, 50));
  fillShaded16Ellipse(image, 36, 19, 2, 2, rgba(220, 180, 50));
  fillCircle(image, 29, 19, 1, rgba(20, 20, 20));
  fillCircle(image, 37, 19, 1, rgba(20, 20, 20));
  addHighlight(image, 27, 18, 1);
  addHighlight(image, 35, 18, 1);

  // Beak
  fillTriangle(image, 30, 23, 34, 23, 32, 27, rgba(200, 170, 50));

  return image;
}

img.Image drawTroll() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Club
  drawThickLine(image, 50, 44, 54, 20, 3, woodBrown);
  fillShaded16Ellipse(image, 55, 18, 4, 5, rgba(90, 65, 35));

  // Legs
  drawShadedLine(image, 25, 48, 25, 58, 5, trollDark);
  drawShadedLine(image, 39, 48, 39, 58, 5, trollDark);
  fillShaded16Ellipse(image, 25, 60, 5, 3, trollDark);
  fillShaded16Ellipse(image, 39, 60, 5, 3, trollDark);

  // Body — large and hunched
  fillShaded16Ellipse(image, 32, 38, 13, 13, trollGreen);
  // Regeneration glow spots
  fillCircle(image, 26, 34, 2, rgba(100, 255, 100, 80));
  fillCircle(image, 38, 40, 2, rgba(100, 255, 100, 80));
  fillCircle(image, 30, 44, 2, rgba(100, 255, 100, 80));

  // Arms — long
  drawShadedLine(image, 18, 32, 12, 48, 5, trollGreen);
  drawShadedLine(image, 46, 32, 50, 44, 5, trollGreen);
  fillShaded16Circle(image, 12, 49, 3, trollDark);
  fillShaded16Circle(image, 50, 45, 3, trollDark);

  // Head
  fillShaded16Circle(image, 32, 18, 9, trollGreen);
  // Big nose
  fillShaded16Ellipse(image, 32, 22, 3, 4, trollDark);
  // Eyes — beady
  fillCircle(image, 27, 17, 2, rgba(200, 200, 50));
  fillCircle(image, 37, 17, 2, rgba(200, 200, 50));
  fillCircle(image, 28, 17, 1, rgba(20, 20, 20));
  fillCircle(image, 38, 17, 1, rgba(20, 20, 20));
  // Warts
  fillCircle(image, 25, 20, 1, rgba(50, 100, 40));
  fillCircle(image, 38, 14, 1, rgba(50, 100, 40));

  return image;
}

img.Image drawWraith() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Ethereal trailing bottom — wispy
  for (int i = 0; i < 5; i++) {
    final x = 24 + i * 4;
    final len = 6 + (i % 3) * 3;
    fillEllipse(image, x, 54 + len ~/ 2, 2, len ~/ 2, rgba(40, 40, 80, 40 + i * 10));
  }

  // Ghostly body — semi-transparent
  fillShaded16Ellipse(image, 32, 38, 11, 14, wraithBlue);
  // Inner glow
  fillEllipse(image, 32, 38, 7, 10, rgba(70, 70, 120, 100));

  // Tattered edges
  fillTriangle(image, 20, 42, 18, 54, 24, 48, rgba(50, 50, 90, 80));
  fillTriangle(image, 44, 42, 46, 54, 40, 48, rgba(50, 50, 90, 80));
  fillTriangle(image, 28, 48, 26, 58, 32, 52, rgba(50, 50, 90, 80));
  fillTriangle(image, 36, 48, 38, 58, 34, 52, rgba(50, 50, 90, 80));

  // Arms — ghostly reaching forward
  drawShadedLine(image, 20, 34, 10, 38, 3, wraithBlue);
  drawShadedLine(image, 44, 34, 54, 38, 3, wraithBlue);
  // Wispy hands
  fillEllipse(image, 8, 38, 3, 2, rgba(80, 80, 140, 100));
  fillEllipse(image, 56, 38, 3, 2, rgba(80, 80, 140, 100));

  // Hood / head
  fillShaded16Circle(image, 32, 18, 10, rgba(40, 35, 60));
  // Dark void face
  fillEllipse(image, 32, 20, 6, 6, rgba(15, 10, 25));
  // Glowing eyes
  fillCircle(image, 28, 18, 2, rgba(200, 200, 255));
  fillCircle(image, 36, 18, 2, rgba(200, 200, 255));
  addHighlight(image, 27, 17, 1, 220);
  addHighlight(image, 35, 17, 1, 220);

  // Eerie glow
  fillCircle(image, 32, 34, 14, rgba(80, 80, 180, 25));

  return image;
}

img.Image drawMinotaur() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Large axe in right hand
  drawThickLine(image, 52, 46, 54, 18, 3, woodBrown);
  fillShaded16Ellipse(image, 58, 16, 6, 5, rgba(170, 175, 185));
  addHighlight(image, 56, 14, 1);

  // Legs — powerful, with hooves
  drawShadedLine(image, 25, 48, 25, 56, 6, minotaurBrown);
  drawShadedLine(image, 39, 48, 39, 56, 6, minotaurBrown);
  fillShaded16Ellipse(image, 25, 58, 5, 3, rgba(50, 35, 20));
  fillShaded16Ellipse(image, 39, 58, 5, 3, rgba(50, 35, 20));

  // Body — very muscular
  fillShaded16Ellipse(image, 32, 38, 13, 13, minotaurBrown);
  // Chest definition
  fillShaded16Ellipse(image, 29, 34, 4, 4, rgba(140, 100, 65));
  fillShaded16Ellipse(image, 35, 34, 4, 4, rgba(140, 100, 65));

  // Arms — massive
  drawShadedLine(image, 17, 32, 12, 44, 6, minotaurBrown);
  drawShadedLine(image, 47, 32, 52, 44, 6, minotaurBrown);
  fillShaded16Circle(image, 12, 46, 3, minotaurDark);
  fillShaded16Circle(image, 52, 46, 3, minotaurDark);

  // Bull head
  fillShaded16Ellipse(image, 32, 18, 10, 8, minotaurBrown);
  // Snout
  fillShaded16Ellipse(image, 32, 24, 5, 3, rgba(100, 65, 40));
  // Nostrils
  fillCircle(image, 30, 24, 1, rgba(40, 25, 15));
  fillCircle(image, 34, 24, 1, rgba(40, 25, 15));
  // Eyes — red and angry
  fillShaded16Ellipse(image, 27, 17, 2, 2, rgba(200, 50, 40));
  fillShaded16Ellipse(image, 37, 17, 2, 2, rgba(200, 50, 40));
  addHighlight(image, 26, 16, 1);
  addHighlight(image, 36, 16, 1);
  fillCircle(image, 28, 17, 1, rgba(20, 10, 10));
  fillCircle(image, 38, 17, 1, rgba(20, 10, 10));

  // Horns — large curving
  drawShadedLine(image, 22, 14, 16, 6, 3, boneWhite);
  drawShadedLine(image, 16, 6, 14, 10, 2, boneShadow);
  drawShadedLine(image, 42, 14, 48, 6, 3, boneWhite);
  drawShadedLine(image, 48, 6, 50, 10, 2, boneShadow);

  // Nose ring
  fillCircle(image, 32, 26, 2, goldAccent);
  fillCircle(image, 32, 26, 1, rgba(200, 170, 40));
  addHighlight(image, 31, 25, 1, 120);

  return image;
}

img.Image drawWyvern() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Facing left
  // Tail — long curving right
  drawShadedLine(image, 48, 40, 58, 34, 3, wyvernGreen);
  drawShadedLine(image, 58, 34, 62, 30, 2, wyvernDark);
  // Tail spike
  fillTriangle(image, 61, 28, 63, 28, 62, 24, rgba(100, 50, 40));

  // Wings — large, bat-like
  // Left wing
  fillTriangle(image, 26, 24, 4, 4, 14, 34, wyvernDark);
  fillTriangle(image, 26, 24, 10, 10, 4, 4, wyvernGreen);
  // Wing membrane
  fillTriangle(image, 20, 28, 8, 8, 10, 30, rgba(90, 130, 80, 180));

  // Right wing (behind body, partially visible)
  fillTriangle(image, 38, 24, 56, 8, 48, 34, wyvernDark);
  fillTriangle(image, 38, 24, 50, 12, 56, 8, wyvernGreen);
  fillTriangle(image, 42, 28, 52, 12, 50, 30, rgba(90, 130, 80, 180));

  // Legs — bird-like
  drawShadedLine(image, 24, 44, 22, 54, 3, wyvernDark);
  drawShadedLine(image, 34, 44, 36, 54, 3, wyvernDark);
  // Claws
  drawThickLine(image, 22, 54, 18, 56, 1, rgba(100, 80, 50));
  drawThickLine(image, 22, 54, 24, 57, 1, rgba(100, 80, 50));
  drawThickLine(image, 36, 54, 33, 56, 1, rgba(100, 80, 50));
  drawThickLine(image, 36, 54, 39, 57, 1, rgba(100, 80, 50));

  // Body
  fillShaded16Ellipse(image, 30, 36, 10, 10, wyvernGreen);
  // Belly scales
  fillShaded16Ellipse(image, 28, 40, 5, 5, rgba(130, 160, 110));

  // Neck
  drawShadedLine(image, 24, 30, 18, 20, 5, wyvernGreen);

  // Head — dragon-like
  fillShaded16Ellipse(image, 14, 18, 7, 5, wyvernGreen);
  // Snout
  fillShaded16Ellipse(image, 8, 20, 4, 3, wyvernDark);
  // Eye
  fillShaded16Circle(image, 12, 16, 2, rgba(230, 200, 50));
  addHighlight(image, 11, 15, 1);
  fillCircle(image, 13, 16, 1, rgba(20, 20, 20));
  // Nostril
  fillCircle(image, 5, 19, 1, rgba(40, 30, 25));

  // Jaw
  fillShaded16Ellipse(image, 10, 22, 5, 2, wyvernDark);
  // Teeth
  setPixel(image, 6, 21, boneWhite);
  setPixel(image, 8, 21, boneWhite);

  return image;
}

img.Image drawLichAcolyte() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Staff with crystal
  drawThickLine(image, 50, 54, 50, 12, 2, rgba(70, 50, 80));
  fillShaded16Circle(image, 50, 10, 3, rgba(160, 80, 220));
  addHighlight(image, 49, 9, 1, 200);
  // Crystal glow
  fillCircle(image, 50, 10, 5, rgba(160, 80, 220, 40));

  // Robe — tattered purple
  fillShaded16Ellipse(image, 32, 50, 10, 8, lichDark);
  // Tattered edges
  fillTriangle(image, 22, 50, 20, 60, 26, 56, lichDark);
  fillTriangle(image, 42, 50, 44, 60, 38, 56, lichDark);

  // Body
  fillShaded16Ellipse(image, 32, 38, 10, 12, lichPurple);

  // Arms — skeletal
  drawThickLine(image, 21, 34, 16, 42, 2, boneShadow);
  drawThickLine(image, 43, 34, 49, 42, 2, boneShadow);
  fillCircle(image, 16, 43, 2, boneShadow);
  fillCircle(image, 49, 43, 2, boneShadow);

  // Skull head
  fillShaded16Circle(image, 32, 18, 8, boneWhite);
  // Eye sockets
  fillCircle(image, 28, 17, 3, rgba(20, 10, 25));
  fillCircle(image, 36, 17, 3, rgba(20, 10, 25));
  // Purple glowing eyes
  fillCircle(image, 28, 17, 1, rgba(180, 60, 240));
  fillCircle(image, 36, 17, 1, rgba(180, 60, 240));
  addHighlight(image, 27, 16, 1, 120);
  addHighlight(image, 35, 16, 1, 120);
  // Jaw
  fillRect(image, 28, 23, 36, 24, boneWhite);
  fillRect(image, 29, 23, 29, 24, rgba(20, 10, 25));
  fillRect(image, 31, 23, 31, 24, rgba(20, 10, 25));
  fillRect(image, 33, 23, 33, 24, rgba(20, 10, 25));
  fillRect(image, 35, 23, 35, 24, rgba(20, 10, 25));

  return image;
}

img.Image drawGolem() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Legs — blocky but rounded
  fillShaded16Ellipse(image, 25, 52, 6, 6, golemGray);
  fillShaded16Ellipse(image, 39, 52, 6, 6, golemGray);

  // Body — massive and blocky
  fillShaded16Ellipse(image, 32, 36, 14, 14, golemGray);
  // Rune markings — glowing blue
  // Chest rune
  drawThickLine(image, 28, 30, 36, 30, 1, rgba(80, 160, 255));
  drawThickLine(image, 32, 28, 32, 36, 1, rgba(80, 160, 255));
  fillCircle(image, 32, 32, 2, rgba(80, 160, 255, 100));
  addHighlight(image, 32, 31, 1, 150);
  // Arm runes
  fillCircle(image, 14, 36, 1, rgba(80, 160, 255));
  fillCircle(image, 50, 36, 1, rgba(80, 160, 255));

  // Arms — huge stone
  fillShaded16Ellipse(image, 14, 36, 6, 8, golemGray);
  fillShaded16Ellipse(image, 50, 36, 6, 8, golemGray);
  // Fists
  fillShaded16Circle(image, 14, 46, 4, golemDark);
  fillShaded16Circle(image, 50, 46, 4, golemDark);

  // Head — small, embedded in shoulders
  fillShaded16Circle(image, 32, 18, 7, golemDark);
  // Eyes — glowing rune eyes
  fillRect(image, 27, 17, 30, 18, rgba(80, 180, 255));
  fillRect(image, 34, 17, 37, 18, rgba(80, 180, 255));
  addHighlight(image, 28, 17, 1, 180);
  addHighlight(image, 35, 17, 1, 180);

  // Cracks
  drawThickLine(image, 26, 28, 22, 38, 1, rgba(90, 90, 95));
  drawThickLine(image, 40, 32, 42, 42, 1, rgba(90, 90, 95));

  return image;
}

img.Image drawVampire() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Cape — dramatic flowing shape
  fillTriangle(image, 12, 22, 6, 56, 32, 56, vampireBlack);
  fillTriangle(image, 52, 22, 58, 56, 32, 56, vampireBlack);
  // Cape inner lining — red
  fillTriangle(image, 16, 26, 12, 50, 30, 50, rgba(140, 20, 20));
  fillTriangle(image, 48, 26, 52, 50, 34, 50, rgba(140, 20, 20));

  // Legs
  drawShadedLine(image, 28, 48, 28, 56, 4, rgba(30, 28, 40));
  drawShadedLine(image, 36, 48, 36, 56, 4, rgba(30, 28, 40));
  fillShaded16Ellipse(image, 28, 57, 4, 2, rgba(25, 22, 35));
  fillShaded16Ellipse(image, 36, 57, 4, 2, rgba(25, 22, 35));

  // Body — slender
  fillShaded16Ellipse(image, 32, 38, 8, 12, vampireBlack);
  // Shirt / vest
  fillShaded16Ellipse(image, 32, 34, 6, 5, rgba(80, 20, 25));

  // Arms
  drawShadedLine(image, 22, 32, 18, 42, 3, vampireBlack);
  drawShadedLine(image, 42, 32, 46, 42, 3, vampireBlack);
  fillShaded16Circle(image, 18, 43, 2, vampireSkin);
  fillShaded16Circle(image, 46, 43, 2, vampireSkin);

  // Head — pale
  fillShaded16Circle(image, 32, 16, 8, vampireSkin);
  // Widow's peak hair
  fillShaded16Ellipse(image, 32, 10, 9, 4, rgba(20, 15, 30));
  fillTriangle(image, 28, 12, 36, 12, 32, 16, rgba(20, 15, 30));

  // Eyes — red and piercing
  fillShaded16Ellipse(image, 28, 15, 2, 2, rgba(200, 30, 30));
  fillShaded16Ellipse(image, 36, 15, 2, 2, rgba(200, 30, 30));
  addHighlight(image, 27, 14, 1, 150);
  addHighlight(image, 35, 14, 1, 150);
  fillCircle(image, 29, 15, 1, rgba(100, 10, 10));
  fillCircle(image, 37, 15, 1, rgba(100, 10, 10));

  // Mouth with fangs
  fillRect(image, 30, 20, 34, 20, rgba(80, 20, 25));
  fillRect(image, 30, 20, 30, 22, boneWhite); // Left fang
  fillRect(image, 34, 20, 34, 22, boneWhite); // Right fang

  return image;
}

img.Image drawChimera() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Facing left — complex multi-creature
  // Snake tail (right side)
  drawShadedLine(image, 48, 38, 56, 30, 3, rgba(60, 100, 50));
  drawShadedLine(image, 56, 30, 60, 24, 2, rgba(60, 100, 50));
  fillShaded16Circle(image, 60, 22, 3, rgba(50, 90, 40));
  // Snake eyes
  fillCircle(image, 59, 21, 1, rgba(230, 200, 40));
  // Snake tongue
  drawThickLine(image, 58, 24, 56, 26, 1, rgba(200, 40, 40));

  // Legs — lion
  drawShadedLine(image, 18, 44, 16, 54, 4, chimeraDark);
  drawShadedLine(image, 24, 44, 22, 54, 4, chimeraDark);
  drawShadedLine(image, 38, 44, 40, 54, 4, chimeraDark);
  drawShadedLine(image, 44, 44, 46, 54, 4, chimeraDark);
  // Paws
  fillShaded16Ellipse(image, 16, 56, 3, 2, chimeraDark);
  fillShaded16Ellipse(image, 22, 56, 3, 2, chimeraDark);
  fillShaded16Ellipse(image, 40, 56, 3, 2, chimeraDark);
  fillShaded16Ellipse(image, 46, 56, 3, 2, chimeraDark);

  // Lion body
  fillShaded16Ellipse(image, 32, 38, 16, 9, chimeraGold);

  // Goat head (on top/back)
  fillShaded16Circle(image, 38, 22, 5, rgba(180, 175, 165));
  // Goat horns
  drawShadedLine(image, 35, 18, 33, 12, 2, rgba(140, 130, 110));
  drawShadedLine(image, 41, 18, 43, 12, 2, rgba(140, 130, 110));
  // Goat eyes
  fillCircle(image, 36, 21, 1, rgba(200, 180, 50));
  fillCircle(image, 40, 21, 1, rgba(200, 180, 50));

  // Lion head (front, main)
  fillShaded16Circle(image, 16, 26, 8, chimeraGold);
  // Mane
  fillShaded16Circle(image, 16, 24, 10, rgba(160, 110, 40));
  fillShaded16Circle(image, 16, 26, 8, chimeraGold);
  // Eyes
  fillShaded16Ellipse(image, 13, 25, 2, 2, rgba(200, 170, 40));
  addHighlight(image, 12, 24, 1);
  fillCircle(image, 14, 25, 1, rgba(20, 20, 20));
  // Nose
  fillCircle(image, 10, 28, 2, rgba(120, 80, 60));
  // Mouth
  fillRect(image, 8, 30, 14, 30, rgba(60, 30, 25));
  // Fangs
  setPixel(image, 9, 31, boneWhite);
  setPixel(image, 13, 31, boneWhite);

  return image;
}

img.Image drawDeathKnight() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Glowing red sword
  drawThickLine(image, 50, 44, 50, 20, 3, rgba(180, 40, 40));
  fillRect(image, 47, 44, 53, 46, rgba(50, 45, 55));
  fillTriangle(image, 48, 20, 52, 20, 50, 14, rgba(200, 50, 40));
  // Glow
  fillEllipse(image, 50, 30, 4, 12, rgba(200, 40, 30, 40));
  addHighlight(image, 50, 24, 1, 140);

  // Armored legs
  drawShadedLine(image, 27, 48, 27, 56, 5, dkArmor);
  drawShadedLine(image, 37, 48, 37, 56, 5, dkArmor);
  fillShaded16Ellipse(image, 27, 58, 5, 3, dkDark);
  fillShaded16Ellipse(image, 37, 58, 5, 3, dkDark);

  // Body — heavy dark plate
  fillShaded16Ellipse(image, 32, 38, 12, 12, dkArmor);
  // Chest plate
  fillShaded16Ellipse(image, 32, 34, 8, 6, rgba(75, 70, 85));
  addHighlight(image, 29, 31, 2, 60);
  // Skull emblem on chest
  fillCircle(image, 32, 34, 3, rgba(180, 170, 150));
  fillRect(image, 30, 33, 31, 34, rgba(20, 15, 20));
  fillRect(image, 33, 33, 34, 34, rgba(20, 15, 20));

  // Arms — armored
  drawShadedLine(image, 18, 32, 14, 44, 5, dkArmor);
  drawShadedLine(image, 46, 32, 50, 44, 5, dkArmor);
  // Gauntlets
  fillShaded16Circle(image, 14, 45, 3, dkDark);
  fillShaded16Circle(image, 50, 45, 3, dkDark);

  // Helmet — ominous
  fillShaded16Circle(image, 32, 16, 9, dkArmor);
  // Visor
  fillRect(image, 24, 14, 40, 18, rgba(20, 15, 25));
  // Glowing red eyes through visor
  fillCircle(image, 28, 16, 2, rgba(200, 40, 30));
  fillCircle(image, 36, 16, 2, rgba(200, 40, 30));
  addHighlight(image, 27, 15, 1, 150);
  addHighlight(image, 35, 15, 1, 150);
  // Helmet crest
  fillTriangle(image, 30, 7, 34, 7, 32, 2, dkDark);

  return image;
}

img.Image drawElderDragon() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Large dragon — fills most of the space
  // Tail curving right
  drawShadedLine(image, 48, 44, 58, 38, 4, dragonDark);
  drawShadedLine(image, 58, 38, 62, 34, 3, dragonDark);
  // Tail spikes
  fillTriangle(image, 60, 32, 63, 32, 62, 28, rgba(130, 40, 30));

  // Wings folded along back
  fillTriangle(image, 28, 20, 8, 6, 20, 36, rgba(140, 40, 30));
  fillTriangle(image, 36, 20, 56, 6, 44, 36, rgba(140, 40, 30));
  // Wing membrane
  fillTriangle(image, 26, 24, 12, 10, 18, 32, rgba(180, 70, 50, 150));
  fillTriangle(image, 38, 24, 52, 10, 46, 32, rgba(180, 70, 50, 150));

  // Legs — powerful
  drawShadedLine(image, 22, 46, 20, 56, 5, dragonDark);
  drawShadedLine(image, 42, 46, 44, 56, 5, dragonDark);
  // Claws
  fillTriangle(image, 17, 56, 16, 60, 20, 58, rgba(100, 80, 60));
  fillTriangle(image, 22, 56, 21, 60, 25, 58, rgba(100, 80, 60));
  fillTriangle(image, 41, 56, 40, 60, 44, 58, rgba(100, 80, 60));
  fillTriangle(image, 46, 56, 45, 60, 49, 58, rgba(100, 80, 60));

  // Body — massive
  fillShaded16Ellipse(image, 32, 40, 14, 10, dragonRed);
  // Belly scales
  fillShaded16Ellipse(image, 32, 44, 8, 5, rgba(200, 130, 80));

  // Neck
  drawShadedLine(image, 28, 32, 28, 22, 6, dragonRed);

  // Head
  fillShaded16Ellipse(image, 28, 16, 8, 6, dragonRed);
  // Snout
  fillShaded16Ellipse(image, 22, 18, 5, 3, dragonDark);
  // Nostrils with fire hint
  fillCircle(image, 19, 17, 1, rgba(255, 140, 30));
  fillCircle(image, 19, 19, 1, rgba(255, 140, 30));
  // Fire breath wisps
  fillCircle(image, 16, 16, 2, rgba(255, 100, 20, 80));
  fillCircle(image, 14, 18, 1, rgba(255, 180, 40, 60));

  // Eyes — fierce orange
  fillShaded16Circle(image, 25, 14, 2, rgba(240, 180, 40));
  fillShaded16Circle(image, 31, 14, 2, rgba(240, 180, 40));
  addHighlight(image, 24, 13, 1);
  addHighlight(image, 30, 13, 1);
  fillCircle(image, 26, 14, 1, rgba(30, 15, 10));
  fillCircle(image, 32, 14, 1, rgba(30, 15, 10));

  // Horns
  drawShadedLine(image, 24, 12, 18, 4, 2, rgba(120, 80, 50));
  drawShadedLine(image, 32, 12, 38, 4, 2, rgba(120, 80, 50));

  return image;
}

img.Image drawArchdemon() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Fire aura
  fillCircle(image, 32, 36, 22, rgba(255, 80, 20, 25));
  fillCircle(image, 32, 36, 16, rgba(255, 100, 30, 20));

  // Wings — bat-like
  fillTriangle(image, 18, 20, 2, 8, 12, 40, demonDark);
  fillTriangle(image, 46, 20, 62, 8, 52, 40, demonDark);
  // Wing membrane
  fillTriangle(image, 16, 24, 6, 12, 14, 36, rgba(160, 35, 25, 180));
  fillTriangle(image, 48, 24, 58, 12, 50, 36, rgba(160, 35, 25, 180));

  // Legs
  drawShadedLine(image, 26, 48, 26, 56, 5, demonDark);
  drawShadedLine(image, 38, 48, 38, 56, 5, demonDark);
  fillShaded16Ellipse(image, 26, 58, 5, 3, rgba(80, 20, 15));
  fillShaded16Ellipse(image, 38, 58, 5, 3, rgba(80, 20, 15));

  // Body — muscular
  fillShaded16Ellipse(image, 32, 38, 12, 12, demonRed);
  // Abs/chest
  fillShaded16Ellipse(image, 32, 34, 6, 5, rgba(200, 55, 40));

  // Arms — clawed
  drawShadedLine(image, 18, 32, 14, 42, 5, demonRed);
  drawShadedLine(image, 46, 32, 50, 42, 5, demonRed);
  fillShaded16Circle(image, 14, 44, 3, demonDark);
  fillShaded16Circle(image, 50, 44, 3, demonDark);

  // Head
  fillShaded16Circle(image, 32, 18, 8, demonRed);
  // Horns — large
  drawShadedLine(image, 24, 14, 18, 4, 3, rgba(60, 25, 15));
  drawShadedLine(image, 18, 4, 16, 2, 2, rgba(80, 35, 20));
  drawShadedLine(image, 40, 14, 46, 4, 3, rgba(60, 25, 15));
  drawShadedLine(image, 46, 4, 48, 2, 2, rgba(80, 35, 20));

  // Eyes — glowing yellow
  fillShaded16Ellipse(image, 28, 17, 2, 2, rgba(255, 220, 50));
  fillShaded16Ellipse(image, 36, 17, 2, 2, rgba(255, 220, 50));
  addHighlight(image, 27, 16, 1, 200);
  addHighlight(image, 35, 16, 1, 200);

  // Fanged mouth
  fillRect(image, 28, 22, 36, 23, rgba(60, 15, 10));
  fillRect(image, 29, 23, 29, 25, boneWhite);
  fillRect(image, 31, 23, 31, 24, boneWhite);
  fillRect(image, 33, 23, 33, 24, boneWhite);
  fillRect(image, 35, 23, 35, 25, boneWhite);

  return image;
}

img.Image drawTitan() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Fills most of the 64x64 — towering
  // Legs — huge pillars
  fillShaded16Ellipse(image, 22, 54, 7, 8, titanGray);
  fillShaded16Ellipse(image, 42, 54, 7, 8, titanGray);

  // Body — massive
  fillShaded16Ellipse(image, 32, 36, 16, 16, titanGray);
  // Chest
  fillShaded16Ellipse(image, 32, 30, 10, 8, rgba(180, 175, 165));
  addHighlight(image, 28, 27, 2, 40);

  // Stone/metal plate details
  fillRect(image, 22, 32, 42, 34, titanDark);
  fillShaded16Circle(image, 32, 33, 2, rgba(80, 160, 255));
  addHighlight(image, 31, 32, 1, 150);

  // Arms — enormous
  fillShaded16Ellipse(image, 12, 34, 7, 12, titanGray);
  fillShaded16Ellipse(image, 52, 34, 7, 12, titanGray);
  // Fists
  fillShaded16Circle(image, 12, 48, 5, titanDark);
  fillShaded16Circle(image, 52, 48, 5, titanDark);

  // Head — small relative to body, embedded
  fillShaded16Circle(image, 32, 14, 7, titanDark);
  // Eyes — glowing
  fillRect(image, 27, 13, 30, 14, rgba(80, 180, 255));
  fillRect(image, 34, 13, 37, 14, rgba(80, 180, 255));
  addHighlight(image, 28, 13, 1, 180);
  addHighlight(image, 35, 13, 1, 180);

  // Crown-like stone ridges
  fillTriangle(image, 25, 10, 27, 4, 29, 10, titanDark);
  fillTriangle(image, 31, 9, 32, 3, 33, 9, titanDark);
  fillTriangle(image, 35, 10, 37, 4, 39, 10, titanDark);

  return image;
}

img.Image drawShadowLord() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Purple energy aura
  fillCircle(image, 32, 34, 20, rgba(80, 30, 140, 20));

  // Ethereal trailing bottom
  for (int i = 0; i < 6; i++) {
    final x = 20 + i * 5;
    final len = 8 + (i % 3) * 4;
    fillEllipse(image, x, 52 + len ~/ 2, 3, len ~/ 2, rgba(30, 15, 50, 50 + i * 8));
  }

  // Body — dark ethereal
  fillShaded16Ellipse(image, 32, 36, 12, 14, shadowDark);
  // Inner shadow energy
  fillEllipse(image, 32, 36, 8, 10, rgba(60, 30, 100, 80));

  // Arms — reaching out with energy
  drawShadedLine(image, 18, 30, 8, 34, 4, shadowDark);
  drawShadedLine(image, 46, 30, 56, 34, 4, shadowDark);
  // Purple energy from hands
  fillCircle(image, 6, 34, 3, rgba(140, 60, 220, 100));
  fillCircle(image, 58, 34, 3, rgba(140, 60, 220, 100));
  addHighlight(image, 5, 33, 1, 100);
  addHighlight(image, 57, 33, 1, 100);

  // Head / hood
  fillShaded16Circle(image, 32, 16, 10, shadowDark);
  // Face void
  fillEllipse(image, 32, 18, 6, 6, rgba(10, 5, 18));

  // Crown
  fillRect(image, 22, 8, 42, 10, rgba(100, 50, 160));
  fillTriangle(image, 24, 8, 26, 3, 28, 8, rgba(120, 60, 180));
  fillTriangle(image, 30, 8, 32, 2, 34, 8, rgba(120, 60, 180));
  fillTriangle(image, 36, 8, 38, 3, 40, 8, rgba(120, 60, 180));
  // Crown gems
  addHighlight(image, 26, 5, 1, 200);
  addHighlight(image, 32, 4, 1, 200);
  addHighlight(image, 38, 5, 1, 200);

  // Eyes — bright purple
  fillCircle(image, 28, 16, 2, rgba(200, 100, 255));
  fillCircle(image, 36, 16, 2, rgba(200, 100, 255));
  addHighlight(image, 27, 15, 1, 220);
  addHighlight(image, 35, 15, 1, 220);

  return image;
}

img.Image drawAncientWyrm() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Serpentine dragon — long sinuous body
  // Body coil (back)
  fillShaded16Ellipse(image, 46, 46, 8, 6, wyrmDark);

  // Body S-curve
  drawShadedLine(image, 46, 42, 38, 34, 6, wyrmTeal);
  drawShadedLine(image, 38, 34, 28, 38, 6, wyrmTeal);
  drawShadedLine(image, 28, 38, 20, 30, 6, wyrmTeal);

  // Belly scales along curve
  fillShaded16Ellipse(image, 42, 42, 3, 3, rgba(100, 170, 150));
  fillShaded16Ellipse(image, 34, 36, 3, 3, rgba(100, 170, 150));
  fillShaded16Ellipse(image, 24, 36, 3, 3, rgba(100, 170, 150));

  // Tail end
  drawShadedLine(image, 50, 48, 58, 52, 3, wyrmDark);
  drawShadedLine(image, 58, 52, 62, 54, 2, wyrmDark);

  // Dorsal spines along body
  fillTriangle(image, 44, 38, 46, 34, 48, 38, rgba(40, 90, 80));
  fillTriangle(image, 36, 32, 38, 28, 40, 32, rgba(40, 90, 80));
  fillTriangle(image, 26, 34, 28, 30, 30, 34, rgba(40, 90, 80));

  // Head — ancient and wise
  fillShaded16Ellipse(image, 16, 24, 8, 6, wyrmTeal);
  // Snout
  fillShaded16Ellipse(image, 8, 26, 5, 3, wyrmDark);
  // Whiskers/tendrils (ancient feature)
  drawThickLine(image, 6, 28, 2, 34, 1, rgba(80, 160, 150));
  drawThickLine(image, 10, 28, 8, 36, 1, rgba(80, 160, 150));

  // Eyes — wise and old, gold
  fillShaded16Circle(image, 13, 22, 2, rgba(220, 200, 60));
  fillShaded16Circle(image, 19, 22, 2, rgba(220, 200, 60));
  addHighlight(image, 12, 21, 1);
  addHighlight(image, 18, 21, 1);
  fillCircle(image, 14, 22, 1, rgba(30, 20, 10));
  fillCircle(image, 20, 22, 1, rgba(30, 20, 10));

  // Horns — long sweeping back
  drawShadedLine(image, 12, 20, 6, 12, 2, rgba(100, 140, 130));
  drawShadedLine(image, 6, 12, 4, 8, 2, rgba(80, 120, 110));
  drawShadedLine(image, 20, 20, 26, 12, 2, rgba(100, 140, 130));
  drawShadedLine(image, 26, 12, 28, 8, 2, rgba(80, 120, 110));

  return image;
}

img.Image drawVoidWalker() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Void energy tendrils
  for (int i = 0; i < 6; i++) {
    final angle = i * pi / 3;
    final sx = 32 + (14 * cos(angle)).round();
    final sy = 36 + (14 * sin(angle)).round();
    final ex = 32 + (24 * cos(angle + 0.3)).round();
    final ey = 36 + (24 * sin(angle + 0.3)).round();
    drawThickLine(image, sx, sy, ex, ey, 2, rgba(100, 40, 180, 80));
    fillCircle(image, ex, ey, 2, rgba(140, 60, 220, 60));
  }

  // Dark void core
  fillCircle(image, 32, 36, 16, rgba(20, 10, 35, 60));

  // Body — otherworldly, geometric
  fillShaded16Ellipse(image, 32, 38, 10, 12, voidBlack);

  // Floating legs (disconnected)
  fillShaded16Ellipse(image, 26, 54, 4, 4, rgba(40, 20, 60));
  fillShaded16Ellipse(image, 38, 54, 4, 4, rgba(40, 20, 60));
  // Connection energy
  drawThickLine(image, 26, 50, 28, 48, 1, rgba(100, 40, 180, 100));
  drawThickLine(image, 38, 50, 36, 48, 1, rgba(100, 40, 180, 100));

  // Arms — elongated, alien
  drawShadedLine(image, 20, 32, 10, 40, 3, voidBlack);
  drawShadedLine(image, 44, 32, 54, 40, 3, voidBlack);
  // Void claws
  fillCircle(image, 8, 42, 2, rgba(120, 50, 200, 120));
  fillCircle(image, 56, 42, 2, rgba(120, 50, 200, 120));

  // Head — alien with multiple angles
  fillShaded16Ellipse(image, 32, 18, 8, 9, voidBlack);

  // Multiple eyes — otherworldly
  // Main eyes
  fillCircle(image, 28, 16, 2, voidPurple);
  fillCircle(image, 36, 16, 2, voidPurple);
  addHighlight(image, 27, 15, 1, 200);
  addHighlight(image, 35, 15, 1, 200);
  // Third eye
  fillCircle(image, 32, 12, 2, rgba(160, 60, 240));
  addHighlight(image, 31, 11, 1, 180);
  // Lower eyes
  fillCircle(image, 30, 20, 1, rgba(120, 50, 200));
  fillCircle(image, 34, 20, 1, rgba(120, 50, 200));

  return image;
}

// ── Boss enemies ────────────────────────────────────────────────────────

img.Image drawBossGoblinKing() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final kingGreen = rgba(70, 150, 50);
  final kingDark = rgba(45, 105, 30);

  // Royal scepter
  drawThickLine(image, 50, 46, 50, 16, 2, goldAccent);
  fillShaded16Circle(image, 50, 14, 4, rgba(200, 50, 50));
  addHighlight(image, 49, 13, 1, 200);
  // Scepter glow
  fillCircle(image, 50, 14, 6, rgba(200, 50, 50, 30));

  // Cape
  fillTriangle(image, 20, 26, 14, 56, 32, 56, rgba(160, 30, 30));
  fillTriangle(image, 44, 26, 50, 56, 32, 56, rgba(160, 30, 30));
  // Cape inner
  fillTriangle(image, 22, 28, 18, 52, 32, 52, rgba(200, 50, 40));
  fillTriangle(image, 42, 28, 46, 52, 32, 52, rgba(200, 50, 40));

  // Legs
  drawShadedLine(image, 27, 48, 27, 56, 4, kingDark);
  drawShadedLine(image, 37, 48, 37, 56, 4, kingDark);
  fillShaded16Ellipse(image, 27, 58, 5, 2, kingDark);
  fillShaded16Ellipse(image, 37, 58, 5, 2, kingDark);

  // Body — larger than regular goblin
  fillShaded16Ellipse(image, 32, 40, 11, 12, kingGreen);
  // Royal belt
  fillRect(image, 21, 42, 43, 44, goldAccent);
  fillShaded16Circle(image, 32, 43, 2, rgba(200, 50, 50));
  addHighlight(image, 31, 42, 1, 150);

  // Arms
  drawShadedLine(image, 20, 36, 14, 46, 4, kingGreen);
  drawShadedLine(image, 44, 36, 50, 46, 4, kingGreen);

  // Head — big
  fillShaded16Circle(image, 32, 22, 11, kingGreen);

  // Pointy ears — bigger
  fillTriangle(image, 17, 20, 20, 14, 20, 26, kingGreen);
  fillTriangle(image, 47, 20, 44, 14, 44, 26, kingGreen);

  // Crown
  fillRect(image, 22, 12, 42, 14, goldAccent);
  fillTriangle(image, 24, 12, 26, 7, 28, 12, goldAccent);
  fillTriangle(image, 30, 12, 32, 6, 34, 12, goldAccent);
  fillTriangle(image, 36, 12, 38, 7, 40, 12, goldAccent);
  // Crown gems
  fillCircle(image, 26, 9, 1, rgba(200, 50, 50));
  fillCircle(image, 32, 8, 1, rgba(50, 100, 220));
  fillCircle(image, 38, 9, 1, rgba(200, 50, 50));
  addHighlight(image, 26, 8, 1, 180);
  addHighlight(image, 32, 7, 1, 180);
  addHighlight(image, 38, 8, 1, 180);

  // Eyes — larger, more cunning
  fillShaded16Ellipse(image, 26, 20, 4, 3, rgba(240, 230, 60));
  fillShaded16Ellipse(image, 38, 20, 4, 3, rgba(240, 230, 60));
  addHighlight(image, 25, 19, 1);
  addHighlight(image, 37, 19, 1);
  fillCircle(image, 27, 21, 1, rgba(20, 20, 20));
  fillCircle(image, 39, 21, 1, rgba(20, 20, 20));

  // Mouth — regal sneer
  fillRect(image, 28, 26, 36, 27, rgba(40, 20, 20));
  fillRect(image, 30, 26, 30, 26, boneWhite);
  fillRect(image, 34, 26, 34, 26, boneWhite);

  return image;
}

img.Image drawBossBoneLord() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  // Dark sword
  drawThickLine(image, 52, 44, 52, 16, 3, rgba(160, 160, 170));
  fillRect(image, 49, 44, 55, 46, rgba(80, 70, 60));
  fillTriangle(image, 50, 16, 54, 16, 52, 10, rgba(170, 170, 180));
  addHighlight(image, 52, 24, 1, 100);

  // Shield in left hand — bone motif
  fillShaded16Ellipse(image, 12, 36, 7, 9, rgba(60, 55, 50));
  fillShaded16Ellipse(image, 12, 36, 5, 7, rgba(80, 75, 65));
  // Skull on shield
  fillCircle(image, 12, 34, 3, boneWhite);
  fillRect(image, 10, 33, 11, 34, rgba(20, 15, 15));
  fillRect(image, 13, 33, 14, 34, rgba(20, 15, 15));

  // Armored legs
  drawShadedLine(image, 27, 48, 27, 58, 5, rgba(70, 65, 55));
  drawShadedLine(image, 37, 48, 37, 58, 5, rgba(70, 65, 55));
  fillShaded16Ellipse(image, 27, 60, 5, 3, rgba(60, 55, 45));
  fillShaded16Ellipse(image, 37, 60, 5, 3, rgba(60, 55, 45));

  // Body — armored skeleton, bone motifs
  fillShaded16Ellipse(image, 32, 38, 12, 12, rgba(70, 65, 55));
  // Ribcage visible through armor gaps
  fillShaded16Ellipse(image, 32, 36, 7, 6, boneWhite);
  for (int i = 0; i < 3; i++) {
    fillRect(image, 26, 32 + i * 3, 38, 32 + i * 3, rgba(50, 45, 40));
  }

  // Arms
  drawShadedLine(image, 18, 32, 12, 42, 4, rgba(70, 65, 55));
  drawShadedLine(image, 46, 32, 52, 42, 4, rgba(70, 65, 55));
  fillShaded16Circle(image, 12, 44, 3, boneShadow);
  fillShaded16Circle(image, 52, 44, 3, boneShadow);

  // Skull with crown
  fillShaded16Circle(image, 32, 18, 10, boneWhite);
  // Eye sockets
  fillCircle(image, 27, 17, 3, rgba(15, 10, 10));
  fillCircle(image, 37, 17, 3, rgba(15, 10, 10));
  // Bright glowing eyes
  fillCircle(image, 27, 17, 2, rgba(200, 60, 60));
  fillCircle(image, 37, 17, 2, rgba(200, 60, 60));
  addHighlight(image, 26, 16, 1, 180);
  addHighlight(image, 36, 16, 1, 180);
  // Nose
  fillTriangle(image, 31, 20, 33, 20, 32, 22, rgba(20, 15, 15));
  // Teeth
  fillRect(image, 27, 24, 37, 25, boneWhite);
  for (int x = 28; x < 37; x += 2) {
    fillRect(image, x, 24, x, 25, rgba(20, 15, 15));
  }

  // Bone crown
  fillRect(image, 22, 10, 42, 12, boneWhite);
  fillTriangle(image, 24, 10, 26, 4, 28, 10, boneWhite);
  fillTriangle(image, 30, 10, 32, 3, 34, 10, boneWhite);
  fillTriangle(image, 36, 10, 38, 4, 40, 10, boneWhite);
  addHighlight(image, 26, 6, 1, 120);
  addHighlight(image, 32, 5, 1, 120);
  addHighlight(image, 38, 6, 1, 120);

  return image;
}

img.Image drawBossShadowWitch() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final witchPurple = rgba(60, 20, 80);
  final witchDark = rgba(35, 10, 50);

  // Magic aura
  fillCircle(image, 32, 36, 18, rgba(120, 50, 200, 15));

  // Floating purple orbs around her
  fillShaded16Circle(image, 10, 28, 3, rgba(160, 70, 230));
  addHighlight(image, 9, 27, 1, 180);
  fillShaded16Circle(image, 54, 24, 3, rgba(160, 70, 230));
  addHighlight(image, 53, 23, 1, 180);
  // Glow
  fillCircle(image, 10, 28, 5, rgba(160, 70, 230, 40));
  fillCircle(image, 54, 24, 5, rgba(160, 70, 230, 40));

  // Robe — long flowing
  fillShaded16Ellipse(image, 32, 50, 12, 10, witchPurple);
  // Tattered bottom
  fillTriangle(image, 20, 52, 16, 62, 24, 58, witchDark);
  fillTriangle(image, 32, 52, 28, 62, 36, 62, witchDark);
  fillTriangle(image, 44, 52, 40, 58, 48, 62, witchDark);

  // Body
  fillShaded16Ellipse(image, 32, 38, 10, 12, witchPurple);
  // Belt
  fillRect(image, 22, 40, 42, 42, rgba(100, 60, 140));
  fillShaded16Circle(image, 32, 41, 2, rgba(200, 80, 255));
  addHighlight(image, 31, 40, 1, 200);

  // Arms — casting magic
  drawShadedLine(image, 20, 34, 12, 38, 3, witchPurple);
  drawShadedLine(image, 44, 34, 52, 32, 3, witchPurple);
  // Magic in hands
  fillCircle(image, 10, 38, 3, rgba(180, 80, 255, 100));
  fillCircle(image, 54, 32, 3, rgba(180, 80, 255, 100));

  // Head
  fillShaded16Circle(image, 32, 20, 8, rgba(160, 140, 160));

  // Pointy witch hat — large
  fillShaded16Ellipse(image, 32, 13, 13, 3, witchPurple);
  fillTriangle(image, 18, 14, 46, 14, 36, -10, witchPurple);
  // Hat buckle
  fillRect(image, 28, 12, 36, 14, rgba(100, 60, 140));
  fillShaded16Circle(image, 32, 13, 2, rgba(200, 80, 255));
  addHighlight(image, 31, 12, 1, 180);
  // Hat tip
  fillCircle(image, 36, -9, 2, rgba(200, 80, 255));
  addHighlight(image, 35, -10, 1, 200);

  // Eyes — glowing purple
  fillShaded16Ellipse(image, 28, 19, 2, 2, rgba(200, 100, 255));
  fillShaded16Ellipse(image, 36, 19, 2, 2, rgba(200, 100, 255));
  addHighlight(image, 27, 18, 1, 220);
  addHighlight(image, 35, 18, 1, 220);

  // Sinister smile
  drawThickLine(image, 28, 24, 36, 24, 1, rgba(80, 30, 50));

  return image;
}

img.Image drawBossMountainGiant() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final giantGray = rgba(130, 125, 115);
  final giantDark = rgba(95, 90, 80);
  final rockColor = rgba(110, 105, 95);

  // Fills nearly the entire frame
  // Legs — massive pillars
  fillShaded16Ellipse(image, 20, 56, 8, 8, giantDark);
  fillShaded16Ellipse(image, 44, 56, 8, 8, giantDark);

  // Body — enormous
  fillShaded16Ellipse(image, 32, 36, 18, 18, giantGray);
  // Rocky skin texture
  fillShaded16Ellipse(image, 26, 30, 3, 3, rockColor);
  fillShaded16Ellipse(image, 38, 34, 4, 3, rockColor);
  fillShaded16Ellipse(image, 30, 42, 3, 2, rockColor);
  // Moss/lichen patches
  fillCircle(image, 22, 38, 2, rgba(70, 120, 60));
  fillCircle(image, 42, 28, 2, rgba(70, 120, 60));

  // Arms — tree-trunk thick
  fillShaded16Ellipse(image, 8, 34, 8, 14, giantGray);
  fillShaded16Ellipse(image, 56, 34, 8, 14, giantGray);
  // Fists — boulder-like
  fillShaded16Circle(image, 8, 50, 6, giantDark);
  fillShaded16Circle(image, 56, 50, 6, giantDark);
  addHighlight(image, 6, 48, 2, 40);
  addHighlight(image, 54, 48, 2, 40);

  // Head — somewhat small, craggy
  fillShaded16Circle(image, 32, 12, 9, giantDark);
  // Brow ridge
  fillRect(image, 23, 10, 41, 12, rgba(100, 95, 85));
  // Eyes — deep set, glowing faintly
  fillCircle(image, 28, 12, 2, rgba(180, 160, 80));
  fillCircle(image, 36, 12, 2, rgba(180, 160, 80));
  addHighlight(image, 27, 11, 1);
  addHighlight(image, 35, 11, 1);
  // Mouth
  fillRect(image, 28, 17, 36, 18, rgba(60, 55, 45));
  // Teeth
  fillRect(image, 29, 17, 29, 18, boneWhite);
  fillRect(image, 35, 17, 35, 18, boneWhite);

  return image;
}

img.Image drawBossLichKing() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final lichRobe = rgba(50, 20, 70);
  final lichRobeDark = rgba(30, 10, 45);

  // Staff with skull
  drawThickLine(image, 52, 56, 52, 12, 3, rgba(60, 50, 80));
  // Skull on top
  fillShaded16Circle(image, 52, 10, 4, boneWhite);
  fillRect(image, 50, 9, 51, 10, rgba(20, 15, 20));
  fillRect(image, 53, 9, 54, 10, rgba(20, 15, 20));
  // Staff glow
  fillCircle(image, 52, 10, 6, rgba(80, 230, 80, 40));
  addHighlight(image, 51, 8, 1, 150);

  // Royal robe — flowing
  fillShaded16Ellipse(image, 32, 50, 14, 10, lichRobe);
  fillTriangle(image, 18, 52, 14, 62, 22, 60, lichRobeDark);
  fillTriangle(image, 32, 54, 28, 62, 36, 62, lichRobeDark);
  fillTriangle(image, 46, 52, 42, 60, 50, 62, lichRobeDark);

  // Body
  fillShaded16Ellipse(image, 32, 38, 12, 14, lichRobe);
  // Royal trim
  fillRect(image, 20, 30, 44, 32, rgba(180, 160, 40));
  // Chest jewel
  fillShaded16Circle(image, 32, 36, 3, rgba(80, 230, 80));
  addHighlight(image, 31, 35, 1, 200);

  // Arms
  drawShadedLine(image, 18, 32, 12, 44, 4, lichRobe);
  drawShadedLine(image, 46, 32, 52, 44, 4, lichRobe);
  // Skeletal hands
  fillCircle(image, 12, 45, 3, boneShadow);
  fillCircle(image, 52, 45, 3, boneShadow);
  // Green glow from hands
  fillCircle(image, 12, 45, 5, rgba(80, 230, 80, 40));

  // Skull
  fillShaded16Circle(image, 32, 16, 10, boneWhite);
  // Eye sockets — deep
  fillCircle(image, 27, 15, 3, rgba(10, 8, 10));
  fillCircle(image, 37, 15, 3, rgba(10, 8, 10));
  // Bright green eyes
  fillCircle(image, 27, 15, 2, rgba(80, 255, 80));
  fillCircle(image, 37, 15, 2, rgba(80, 255, 80));
  addHighlight(image, 26, 14, 1, 200);
  addHighlight(image, 36, 14, 1, 200);
  // Nose
  fillTriangle(image, 31, 18, 33, 18, 32, 21, rgba(15, 10, 10));
  // Jaw with teeth
  fillRect(image, 26, 22, 38, 24, boneWhite);
  for (int x = 27; x < 38; x += 2) {
    fillRect(image, x, 22, x, 24, rgba(15, 10, 10));
  }

  // Crown — ornate
  fillRect(image, 22, 8, 42, 10, goldAccent);
  fillTriangle(image, 23, 8, 25, 2, 27, 8, goldAccent);
  fillTriangle(image, 29, 8, 31, 1, 33, 8, goldAccent);
  fillTriangle(image, 35, 8, 37, 2, 39, 8, goldAccent);
  // Crown gems — green to match
  fillCircle(image, 25, 4, 1, rgba(80, 230, 80));
  fillCircle(image, 31, 3, 1, rgba(80, 230, 80));
  fillCircle(image, 37, 4, 1, rgba(80, 230, 80));
  addHighlight(image, 25, 3, 1, 200);
  addHighlight(image, 31, 2, 1, 200);
  addHighlight(image, 37, 3, 1, 200);

  return image;
}

img.Image drawBossDemonPrince() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final princeDemon = rgba(190, 45, 30);
  final princeDark = rgba(140, 30, 20);

  // Fire aura — intense
  fillCircle(image, 32, 36, 26, rgba(255, 80, 20, 15));
  fillCircle(image, 32, 36, 20, rgba(255, 100, 30, 15));

  // Wings — large and ornate
  fillTriangle(image, 16, 18, 0, 2, 10, 42, princeDark);
  fillTriangle(image, 48, 18, 63, 2, 54, 42, princeDark);
  // Wing membrane with detail
  fillTriangle(image, 14, 22, 4, 6, 12, 38, rgba(170, 40, 30, 180));
  fillTriangle(image, 50, 22, 60, 6, 52, 38, rgba(170, 40, 30, 180));
  // Wing bone spikes
  drawShadedLine(image, 14, 20, 4, 6, 2, rgba(100, 30, 20));
  drawShadedLine(image, 50, 20, 60, 6, 2, rgba(100, 30, 20));

  // Legs — armored
  drawShadedLine(image, 25, 48, 25, 58, 5, rgba(100, 30, 20));
  drawShadedLine(image, 39, 48, 39, 58, 5, rgba(100, 30, 20));
  // Hooves
  fillShaded16Ellipse(image, 25, 60, 5, 3, rgba(50, 20, 15));
  fillShaded16Ellipse(image, 39, 60, 5, 3, rgba(50, 20, 15));

  // Body — armored, muscular
  fillShaded16Ellipse(image, 32, 38, 13, 13, princeDemon);
  // Armor plate
  fillShaded16Ellipse(image, 32, 34, 8, 7, rgba(60, 50, 60));
  addHighlight(image, 29, 31, 2, 50);
  // Glowing rune on chest
  fillCircle(image, 32, 34, 2, rgba(255, 180, 50));
  addHighlight(image, 31, 33, 1, 200);

  // Arms — massive with gauntlets
  drawShadedLine(image, 17, 30, 10, 44, 6, princeDemon);
  drawShadedLine(image, 47, 30, 54, 44, 6, princeDemon);
  // Spiked gauntlets
  fillShaded16Circle(image, 10, 46, 4, rgba(60, 50, 60));
  fillShaded16Circle(image, 54, 46, 4, rgba(60, 50, 60));
  addHighlight(image, 8, 44, 1, 60);
  addHighlight(image, 52, 44, 1, 60);

  // Head
  fillShaded16Circle(image, 32, 18, 9, princeDemon);

  // Ornate horns — large sweeping
  drawShadedLine(image, 22, 14, 14, 4, 3, rgba(70, 25, 15));
  drawShadedLine(image, 14, 4, 10, 0, 2, rgba(90, 35, 25));
  drawShadedLine(image, 42, 14, 50, 4, 3, rgba(70, 25, 15));
  drawShadedLine(image, 50, 4, 54, 0, 2, rgba(90, 35, 25));
  // Horn tips glow
  addHighlight(image, 10, 0, 1, 100);
  addHighlight(image, 54, 0, 1, 100);

  // Eyes — blazing
  fillShaded16Ellipse(image, 28, 17, 3, 2, rgba(255, 220, 50));
  fillShaded16Ellipse(image, 36, 17, 3, 2, rgba(255, 220, 50));
  addHighlight(image, 27, 16, 1, 220);
  addHighlight(image, 35, 16, 1, 220);

  // Fanged grin
  fillRect(image, 27, 22, 37, 24, rgba(60, 15, 10));
  for (int x = 28; x <= 36; x += 2) {
    fillRect(image, x, 22, x, 25, boneWhite);
  }

  return image;
}

img.Image drawBossDragonEmperor() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final dragonGold = rgba(200, 170, 50);
  final dragonGoldDark = rgba(150, 125, 30);

  // Wings spread — majestic
  // Left wing
  fillTriangle(image, 22, 18, 0, 0, 8, 40, dragonGoldDark);
  fillTriangle(image, 22, 18, 4, 4, 0, 0, dragonGold);
  // Wing membrane
  fillTriangle(image, 18, 22, 4, 8, 10, 36, rgba(220, 190, 80, 160));
  // Wing spars
  drawShadedLine(image, 20, 20, 4, 6, 2, dragonGoldDark);
  drawShadedLine(image, 18, 24, 2, 18, 1, dragonGoldDark);

  // Right wing
  fillTriangle(image, 42, 18, 63, 0, 56, 40, dragonGoldDark);
  fillTriangle(image, 42, 18, 60, 4, 63, 0, dragonGold);
  fillTriangle(image, 46, 22, 60, 8, 54, 36, rgba(220, 190, 80, 160));
  drawShadedLine(image, 44, 20, 60, 6, 2, dragonGoldDark);
  drawShadedLine(image, 46, 24, 62, 18, 1, dragonGoldDark);

  // Legs
  drawShadedLine(image, 24, 48, 22, 56, 5, dragonGoldDark);
  drawShadedLine(image, 40, 48, 42, 56, 5, dragonGoldDark);
  // Claws
  fillTriangle(image, 18, 56, 17, 60, 22, 58, rgba(140, 100, 30));
  fillTriangle(image, 24, 56, 23, 60, 28, 58, rgba(140, 100, 30));
  fillTriangle(image, 38, 56, 37, 60, 42, 58, rgba(140, 100, 30));
  fillTriangle(image, 44, 56, 43, 60, 48, 58, rgba(140, 100, 30));

  // Body — majestic
  fillShaded16Ellipse(image, 32, 40, 14, 12, dragonGold);
  // Belly plates
  fillShaded16Ellipse(image, 32, 44, 8, 6, rgba(240, 220, 120));

  // Neck
  drawShadedLine(image, 32, 30, 32, 20, 7, dragonGold);
  // Neck scales
  fillCircle(image, 29, 24, 1, dragonGoldDark);
  fillCircle(image, 35, 26, 1, dragonGoldDark);

  // Head — regal
  fillShaded16Ellipse(image, 32, 14, 9, 7, dragonGold);
  // Snout
  fillShaded16Ellipse(image, 32, 18, 5, 3, dragonGoldDark);
  // Nostrils
  fillCircle(image, 30, 18, 1, rgba(100, 75, 20));
  fillCircle(image, 34, 18, 1, rgba(100, 75, 20));

  // Crown/horns — imperial
  drawShadedLine(image, 24, 10, 18, 2, 2, goldAccent);
  drawShadedLine(image, 40, 10, 46, 2, 2, goldAccent);
  // Central crown horn
  drawShadedLine(image, 32, 8, 32, 0, 2, goldAccent);
  fillCircle(image, 32, 0, 2, rgba(255, 80, 50));
  addHighlight(image, 31, -1, 1, 200);

  // Eyes — regal gold
  fillShaded16Circle(image, 27, 12, 3, rgba(255, 230, 80));
  fillShaded16Circle(image, 37, 12, 3, rgba(255, 230, 80));
  addHighlight(image, 26, 11, 1, 180);
  addHighlight(image, 36, 11, 1, 180);
  fillCircle(image, 28, 12, 1, rgba(80, 50, 10));
  fillCircle(image, 38, 12, 1, rgba(80, 50, 10));

  return image;
}

img.Image drawBossTheDarkOne() {
  final image = img.Image(width: 64, height: 64, numChannels: 4);

  final darkVoid = rgba(15, 8, 25);
  final darkEnergy = rgba(80, 30, 120);

  // Cosmic horror background tendrils
  for (int i = 0; i < 8; i++) {
    final angle = i * pi / 4 + 0.2;
    final sx = 32 + (10 * cos(angle)).round();
    final sy = 32 + (10 * sin(angle)).round();
    final ex = 32 + (28 * cos(angle + 0.15)).round();
    final ey = 32 + (28 * sin(angle + 0.15)).round();
    drawThickLine(image, sx, sy, ex, ey, 2, rgba(60, 20, 100, 60));
    // Tendril tips
    fillCircle(image, ex, ey, 2, rgba(100, 40, 160, 50));
  }

  // Dark void aura
  fillCircle(image, 32, 32, 22, rgba(40, 15, 60, 25));
  fillCircle(image, 32, 32, 16, rgba(30, 10, 50, 30));

  // Main body — amorphous dark mass
  fillShaded16Ellipse(image, 32, 34, 14, 16, darkVoid);
  // Inner energy patterns
  fillEllipse(image, 32, 34, 10, 12, rgba(50, 20, 80, 60));
  // Pulsing energy veins
  drawThickLine(image, 22, 28, 28, 40, 1, rgba(120, 50, 180, 80));
  drawThickLine(image, 42, 28, 36, 40, 1, rgba(120, 50, 180, 80));
  drawThickLine(image, 28, 22, 36, 44, 1, rgba(120, 50, 180, 80));

  // Ethereal arms — elongated and otherworldly
  drawShadedLine(image, 16, 30, 4, 28, 4, darkVoid);
  drawShadedLine(image, 48, 30, 60, 28, 4, darkVoid);
  // Claws with energy
  fillCircle(image, 2, 28, 3, rgba(120, 50, 180, 80));
  fillCircle(image, 62, 28, 3, rgba(120, 50, 180, 80));

  // Multiple eyes — the cosmic horror signature
  // Main eye row
  fillCircle(image, 24, 24, 3, rgba(200, 50, 255));
  fillCircle(image, 32, 22, 3, rgba(200, 50, 255));
  fillCircle(image, 40, 24, 3, rgba(200, 50, 255));
  addHighlight(image, 23, 23, 1, 220);
  addHighlight(image, 31, 21, 1, 220);
  addHighlight(image, 39, 23, 1, 220);
  // Pupils
  fillCircle(image, 25, 24, 1, rgba(10, 5, 15));
  fillCircle(image, 33, 22, 1, rgba(10, 5, 15));
  fillCircle(image, 41, 24, 1, rgba(10, 5, 15));

  // Secondary eyes (smaller)
  fillCircle(image, 28, 18, 2, rgba(180, 40, 230));
  fillCircle(image, 36, 18, 2, rgba(180, 40, 230));
  addHighlight(image, 27, 17, 1, 180);
  addHighlight(image, 35, 17, 1, 180);

  // Third row — tiny
  fillCircle(image, 26, 30, 1, rgba(160, 40, 210));
  fillCircle(image, 32, 28, 1, rgba(160, 40, 210));
  fillCircle(image, 38, 30, 1, rgba(160, 40, 210));

  // Central great eye
  fillShaded16Circle(image, 32, 38, 4, rgba(255, 100, 255));
  fillCircle(image, 32, 38, 2, rgba(10, 5, 15));
  addHighlight(image, 30, 36, 2, 200);

  // Maw — dark void mouth
  fillEllipse(image, 32, 46, 6, 3, rgba(5, 2, 10));
  // Void teeth
  fillTriangle(image, 27, 44, 28, 44, 27, 47, rgba(100, 60, 140));
  fillTriangle(image, 37, 44, 36, 44, 37, 47, rgba(100, 60, 140));

  return image;
}

// ── Main ────────────────────────────────────────────────────────────────

void main() {
  final enemies = <String, img.Image Function()>{
    // Regular enemies
    'goblin': drawGoblin,
    'wolf': drawWolf,
    'bandit': drawBandit,
    'skeleton': drawSkeleton,
    'orc_grunt': drawOrcGrunt,
    'giant_spider': drawGiantSpider,
    'dark_mage': drawDarkMage,
    'ogre': drawOgre,
    'harpy': drawHarpy,
    'troll': drawTroll,
    'wraith': drawWraith,
    'minotaur': drawMinotaur,
    'wyvern': drawWyvern,
    'lich_acolyte': drawLichAcolyte,
    'golem': drawGolem,
    'vampire': drawVampire,
    'chimera': drawChimera,
    'death_knight': drawDeathKnight,
    'elder_dragon': drawElderDragon,
    'archdemon': drawArchdemon,
    'titan': drawTitan,
    'shadow_lord': drawShadowLord,
    'ancient_wyrm': drawAncientWyrm,
    'void_walker': drawVoidWalker,
    // Bosses
    'boss_goblin_king': drawBossGoblinKing,
    'boss_bone_lord': drawBossBoneLord,
    'boss_shadow_witch': drawBossShadowWitch,
    'boss_mountain_giant': drawBossMountainGiant,
    'boss_lich_king': drawBossLichKing,
    'boss_demon_prince': drawBossDemonPrince,
    'boss_dragon_emperor': drawBossDragonEmperor,
    'boss_the_dark_one': drawBossTheDarkOne,
  };

  final dir = 'assets/sprites/enemies';
  Directory(dir).createSync(recursive: true);

  for (final entry in enemies.entries) {
    final name = entry.key;
    final drawFn = entry.value;
    stdout.write('Generating $name... ');
    final image = drawFn();
    saveSprite(image, '$dir/$name');
    stdout.writeln('done');
  }

  print('\nAll ${enemies.length} enemy sprites generated (64x64 + 240x240).');
}
