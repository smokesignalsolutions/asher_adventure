import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

import 'sprite_helpers.dart';

// ── Body layout constants ─────────────────────────────────────────────
const _headCx = 32, _headCy = 15, _headR = 8;
const _bodyCx = 32, _bodyCy = 34, _bodyRx = 10, _bodyRy = 12;
const _armLx = 19, _armRx = 45, _armCy = 33, _armRx2 = 4, _armRy2 = 7;
const _handLx = 19, _handRx = 45, _handY = 39, _handR = 3;
const _legLx = 27, _legRx = 37, _legCy = 50, _legRxR = 4, _legRyR = 6;
const _footLx = 27, _footRx = 37, _footCy = 55, _footRx2 = 5, _footRy2 = 3;

// ── Class body colors ─────────────────────────────────────────────────
final _steelBlue = rgba(100, 120, 160);
final _darkGreen = rgba(60, 100, 60);
final _clericWhite = rgba(230, 230, 235);
final _purple = rgba(120, 60, 160);
final _gold = rgba(220, 190, 60);
final _forestGreen = rgba(70, 130, 70);
final _darkPurple = rgba(80, 40, 110);
final _royalBlue = rgba(50, 80, 180);
final _teal = rgba(60, 140, 140);
final _earthBrown = rgba(120, 100, 60);
final _orange = rgba(220, 140, 40);
final _brown = rgba(140, 100, 60);
final _crimson = rgba(180, 40, 50);
final _necroBlack = rgba(40, 40, 50);
final _copper = rgba(180, 130, 70);
final _templarWhite = rgba(230, 230, 240);

// ── Accent / secondary colors ─────────────────────────────────────────
final _bootBrown = rgba(90, 60, 35);
final _beltBrown = rgba(80, 55, 30);
final _mouthColor = rgba(180, 120, 100);
final _bandageBeige = rgba(220, 210, 190);
final _skullWhite = rgba(220, 220, 200);
final _goggleLens = rgba(150, 200, 230);
final _leafGreen = rgba(60, 150, 50);
final _leafBright = rgba(80, 180, 60);

// ── Common drawing routines ───────────────────────────────────────────

img.Image _newSprite() =>
    img.Image(width: 64, height: 64, numChannels: 4);

/// Draws the full base body with 16-bit shading on every part.
/// [bodyColor] = main torso / arm color.
/// [bootColor] overrides leg/foot color (defaults to _bootBrown).
/// [accentColor] is used for belt and trim details.
void _drawBody(
  img.Image im, {
  required img.ColorRgba8 bodyColor,
  img.ColorRgba8? bootColor,
  img.ColorRgba8? accentColor,
}) {
  final boots = bootColor ?? _bootBrown;

  // ── Legs & feet ──
  fillShaded16Ellipse(im, _legLx, _legCy, _legRxR, _legRyR, bodyColor);
  fillShaded16Ellipse(im, _legRx, _legCy, _legRxR, _legRyR, bodyColor);
  fillShaded16Ellipse(im, _footLx, _footCy, _footRx2, _footRy2, boots);
  fillShaded16Ellipse(im, _footRx, _footCy, _footRx2, _footRy2, boots);
  // Boot tops (1px line across top of feet)
  drawThickLine(im, _footLx - 4, _footCy - 3, _footLx + 4, _footCy - 3, 1, darken(boots, 20));
  drawThickLine(im, _footRx - 4, _footCy - 3, _footRx + 4, _footCy - 3, 1, darken(boots, 20));

  // ── Torso ──
  fillShaded16Ellipse(im, _bodyCx, _bodyCy, _bodyRx, _bodyRy, bodyColor);

  // Belt line across waist
  final belt = accentColor ?? _beltBrown;
  fillRect(im, _bodyCx - _bodyRx + 2, _bodyCy + 3,
      _bodyCx + _bodyRx - 2, _bodyCy + 4, belt);
  // Belt buckle
  fillRect(im, _bodyCx - 1, _bodyCy + 3, _bodyCx + 1, _bodyCy + 4,
      lighten(belt, 30));

  // ── Arms ──
  fillShaded16Ellipse(im, _armLx, _armCy, _armRx2, _armRy2, bodyColor);
  fillShaded16Ellipse(im, _armRx, _armCy, _armRx2, _armRy2, bodyColor);

  // ── Hands ──
  fillShaded16Circle(im, _handLx, _handY, _handR, skin);
  fillShaded16Circle(im, _handRx, _handY, _handR, skin);

  // ── Head ──
  fillShaded16Circle(im, _headCx, _headCy, _headR, skin);
  addHighlight(im, _headCx - 3, _headCy - 3, 2, 120);

  // ── Eyes (2x2 with 1px white highlight) ──
  fillRect(im, 28, 14, 29, 15, eyeColor);
  setPixel(im, 28, 14, rgba(255, 255, 255));  // highlight dot
  fillRect(im, 34, 14, 35, 15, eyeColor);
  setPixel(im, 34, 14, rgba(255, 255, 255));  // highlight dot

  // ── Mouth (subtle line) ──
  fillRect(im, 30, 19, 33, 19, _mouthColor);
}

// ── Headgear (16-bit versions) ────────────────────────────────────────

void _drawHelmet(img.Image im, img.ColorRgba8 color) {
  fillShaded16Ellipse(im, 32, 12, 10, 8, color);
  addHighlight(im, 28, 9, 2, 140);
  // Visor slit
  fillRect(im, 26, 14, 38, 15, rgba(20, 20, 30));
  // Nose guard
  fillRect(im, 31, 14, 33, 18, color);
}

void _drawHood(img.Image im, img.ColorRgba8 color) {
  fillShaded16Circle(im, 32, 14, 11, color);
  // Cut out face
  fillShaded16Ellipse(im, 30, 17, 7, 6, skin);
  // Re-draw eyes
  fillRect(im, 28, 14, 29, 15, eyeColor);
  setPixel(im, 28, 14, rgba(255, 255, 255));
  fillRect(im, 34, 14, 35, 15, eyeColor);
  setPixel(im, 34, 14, rgba(255, 255, 255));
  fillRect(im, 30, 19, 33, 19, _mouthColor);
}

void _drawPointedHat(img.Image im, img.ColorRgba8 color) {
  // Brim
  fillShaded16Ellipse(im, 32, 9, 12, 3, color);
  // Cone
  fillTriangle(im, 20, 10, 44, 10, 35, -8, color);
  // Star at tip
  fillShaded16Circle(im, 35, -6, 2, goldAccent);
  addHighlight(im, 35, -7, 1, 200);
}

void _drawHornedHelmet(img.Image im, img.ColorRgba8 color) {
  fillShaded16Ellipse(im, 32, 13, 10, 7, color);
  // Face opening
  fillShaded16Ellipse(im, 32, 17, 7, 5, skin);
  // Re-draw eyes
  fillRect(im, 28, 14, 29, 15, eyeColor);
  setPixel(im, 28, 14, rgba(255, 255, 255));
  fillRect(im, 34, 14, 35, 15, eyeColor);
  setPixel(im, 34, 14, rgba(255, 255, 255));
  // Horns
  fillTriangle(im, 20, 12, 23, 8, 16, 2, color);
  fillTriangle(im, 44, 12, 41, 8, 48, 2, color);
  addHighlight(im, 17, 4, 1, 150);
  addHighlight(im, 47, 4, 1, 150);
}

void _drawGoggles(img.Image im) {
  // Strap
  fillRect(im, 22, 12, 42, 13, darken(_copper, 30));
  // Left lens
  fillShaded16Circle(im, 28, 12, 3, _goggleLens);
  addHighlight(im, 27, 11, 1, 200);
  // Right lens
  fillShaded16Circle(im, 36, 12, 3, _goggleLens);
  addHighlight(im, 35, 11, 1, 200);
}

void _drawWreath(img.Image im) {
  for (int angle = 0; angle < 360; angle += 25) {
    final rad = angle * pi / 180;
    final lx = 32 + (10 * cos(rad)).round();
    final ly = 14 + (8 * sin(rad)).round();
    if (ly < 16) {
      fillShaded16Circle(im, lx, ly, 2, _leafGreen);
    }
  }
}


// ── Equipment drawing (16-bit versions) ───────────────────────────────

void _drawSword(img.Image im, int x, int handY, img.ColorRgba8 bladeColor,
    img.ColorRgba8 handleColor) {
  // Handle
  drawShadedLine(im, x, handY, x, handY + 6, 3, handleColor);
  // Crossguard
  fillRect(im, x - 3, handY - 1, x + 3, handY, goldAccent);
  addHighlight(im, x - 2, handY - 1, 1, 140);
  // Blade
  drawShadedLine(im, x, handY - 2, x, handY - 16, 3, bladeColor);
  // Blade tip
  fillTriangle(im, x - 1, handY - 16, x + 1, handY - 16, x, handY - 19, bladeColor);
  // Specular on blade
  addHighlight(im, x - 1, handY - 10, 1, 160);
}

void _drawDagger(img.Image im, int x, int handY, img.ColorRgba8 bladeColor) {
  drawShadedLine(im, x, handY, x, handY + 3, 2, darken(woodBrown, 15));
  fillRect(im, x - 2, handY - 1, x + 2, handY, silver);
  drawShadedLine(im, x, handY - 1, x, handY - 9, 2, bladeColor);
  fillTriangle(im, x - 1, handY - 9, x + 1, handY - 9, x, handY - 12, bladeColor);
  addHighlight(im, x, handY - 6, 1, 150);
}

void _drawStaff(img.Image im, int x, img.ColorRgba8 staffColor,
    img.ColorRgba8 topColor, {int topRadius = 4}) {
  drawShadedLine(im, x, 10, x, 54, 3, staffColor);
  fillShaded16Circle(im, x, 8, topRadius, topColor);
  addHighlight(im, x - 1, 6, 1, 180);
}

void _drawBow(img.Image im, int x, img.ColorRgba8 bowColor) {
  for (int i = -12; i <= 12; i++) {
    final bx = x - (3 * cos(i * pi / 24)).round();
    final by = 34 + i;
    fillShaded16Circle(im, bx, by, 1, bowColor);
  }
  drawThickLine(im, x, 22, x, 46, 1, rgba(200, 200, 200));
  drawShadedLine(im, x + 1, 22, x + 1, 42, 1, woodBrown);
  fillTriangle(im, x - 1, 20, x + 3, 20, x + 1, 17, silver);
}

void _drawAxe(img.Image im, int x, int handY, img.ColorRgba8 headColor) {
  drawShadedLine(im, x, handY + 4, x, handY - 14, 2, woodBrown);
  fillShaded16Ellipse(im, x + 5, handY - 10, 6, 5, headColor);
  addHighlight(im, x + 3, handY - 12, 1, 160);
}

void _drawMace(img.Image im, int x, int handY, img.ColorRgba8 headColor) {
  drawShadedLine(im, x, handY + 3, x, handY - 10, 2, woodBrown);
  fillShaded16Circle(im, x, handY - 12, 4, headColor);
  addHighlight(im, x - 1, handY - 14, 1, 170);
}

void _drawShield(img.Image im, int x, int y, img.ColorRgba8 shieldColor,
    img.ColorRgba8 trimColor) {
  fillShaded16Ellipse(im, x, y, 6, 8, shieldColor);
  fillShaded16Ellipse(im, x, y - 1, 5, 6, trimColor);
  fillShaded16Ellipse(im, x, y, 4, 6, shieldColor);
  addHighlight(im, x - 2, y - 3, 2, 130);
}

void _drawOrb(img.Image im, int x, int y, img.ColorRgba8 color,
    img.ColorRgba8 glow) {
  fillCircle(im, x, y, 5, glow);
  fillShaded16Circle(im, x, y, 3, color);
  addHighlight(im, x - 1, y - 1, 1, 200);
}

void _drawWrench(img.Image im, int x, int handY) {
  final metalGrey = rgba(160, 160, 170);
  drawShadedLine(im, x, handY + 2, x, handY - 10, 2, metalGrey);
  // Wrench head (open-ended)
  fillShaded16Circle(im, x, handY - 12, 3, metalGrey);
  fillRect(im, x - 1, handY - 14, x + 1, handY - 12, rgba(100, 100, 110));
  addHighlight(im, x - 1, handY - 13, 1, 140);
}

void _drawGearOnBody(img.Image im) {
  final metalGrey = rgba(160, 160, 170);
  fillShaded16Circle(im, 32, 34, 4, metalGrey);
  fillShaded16Circle(im, 32, 34, 2, darken(_copper, 20));
  // Gear teeth (small nubs)
  for (int angle = 0; angle < 360; angle += 45) {
    final rad = angle * pi / 180;
    final gx = 32 + (5 * cos(rad)).round();
    final gy = 34 + (5 * sin(rad)).round();
    setPixel(im, gx, gy, metalGrey);
  }
}

// ── Trim accent helpers ───────────────────────────────────────────────

/// Draw a horizontal trim line across the body at the given y.
void _drawTrim(img.Image im, int y, img.ColorRgba8 color) {
  fillRect(im, _bodyCx - _bodyRx + 3, y, _bodyCx + _bodyRx - 3, y, color);
}

// ── 16 Character class sprites ────────────────────────────────────────

img.Image _drawFighter() {
  final im = _newSprite();
  _drawSword(im, 48, 38, silver, woodBrown);
  _drawBody(im, bodyColor: _steelBlue, accentColor: darken(_steelBlue, 20));
  // Shoulder trim
  _drawTrim(im, 24, lighten(_steelBlue, 20));
  _drawHelmet(im, _steelBlue);
  return im;
}

img.Image _drawRogue() {
  final im = _newSprite();
  _drawDagger(im, 48, 38, silver);
  _drawBody(im, bodyColor: _darkGreen, bootColor: rgba(50, 50, 40),
      accentColor: darken(_darkGreen, 15));
  // Leather strap across chest
  drawThickLine(im, 24, 26, 40, 40, 1, darken(_darkGreen, 25));
  _drawHood(im, _darkGreen);
  return im;
}

img.Image _drawCleric() {
  final im = _newSprite();
  _drawStaff(im, 50, woodBrown, goldAccent);
  _drawBody(im, bodyColor: _clericWhite, accentColor: goldAccent,
      bootColor: rgba(180, 170, 150));
  // Gold trim at waist and collar
  _drawTrim(im, 25, goldAccent);
  return im;
}

img.Image _drawWizard() {
  final im = _newSprite();
  _drawStaff(im, 50, woodBrown, blueGlow);
  _drawBody(im, bodyColor: _purple, accentColor: goldAccent);
  // Robe trim
  _drawTrim(im, 44, goldAccent);
  _drawPointedHat(im, _purple);
  return im;
}

img.Image _drawPaladin() {
  final im = _newSprite();
  _drawSword(im, 50, 38, silver, woodBrown);
  _drawShield(im, 14, 34, _gold, darken(_gold, 20));
  _drawBody(im, bodyColor: _gold, accentColor: lighten(_gold, 15));
  // Chest plate highlight
  addHighlight(im, 30, 30, 3, 100);
  _drawHelmet(im, _gold);
  return im;
}

img.Image _drawRanger() {
  final im = _newSprite();
  _drawBow(im, 14, _forestGreen);
  _drawBody(im, bodyColor: _forestGreen, bootColor: rgba(80, 60, 35),
      accentColor: darken(_forestGreen, 15));
  // Quiver hint on back (small brown rectangle)
  fillRect(im, 39, 24, 41, 36, darken(woodBrown, 10));
  fillRect(im, 38, 23, 42, 24, woodBrown);
  _drawHood(im, _forestGreen);
  return im;
}

img.Image _drawWarlock() {
  final im = _newSprite();
  _drawOrb(im, 50, 36, redAccent, rgba(255, 60, 40, 80));
  _drawBody(im, bodyColor: _darkPurple, accentColor: rgba(140, 60, 160));
  // Purple trim on robe
  _drawTrim(im, 44, rgba(140, 60, 160));
  _drawHood(im, _darkPurple);
  return im;
}

img.Image _drawSummoner() {
  final im = _newSprite();
  // Floating cyan orb above right hand
  _drawOrb(im, 48, 28, cyanGlow, rgba(80, 220, 220, 80));
  _drawBody(im, bodyColor: _royalBlue, accentColor: rgba(80, 120, 220));
  // Arcane trim
  _drawTrim(im, 25, rgba(80, 180, 220));
  _drawTrim(im, 44, rgba(80, 180, 220));
  return im;
}

img.Image _drawSpellsword() {
  final im = _newSprite();
  // Sword with blue glow aura
  _drawSword(im, 48, 38, silver, woodBrown);
  fillEllipse(im, 48, 28, 4, 10, rgba(100, 160, 255, 60));
  _drawBody(im, bodyColor: _teal, accentColor: blueGlow);
  // Arcane runes at waist
  _drawTrim(im, 25, blueGlow);
  return im;
}

img.Image _drawDruid() {
  final im = _newSprite();
  _drawStaff(im, 50, woodBrown, rgba(60, 150, 50));
  // Extra leaves on staff top
  fillShaded16Circle(im, 48, 6, 2, _leafBright);
  fillShaded16Circle(im, 52, 8, 2, _leafGreen);
  _drawBody(im, bodyColor: _earthBrown, accentColor: _leafGreen,
      bootColor: rgba(90, 75, 40));
  // Leaf accent on chest
  fillShaded16Circle(im, 32, 29, 2, _leafGreen);
  _drawWreath(im);
  return im;
}

img.Image _drawMonk() {
  final im = _newSprite();
  _drawBody(im, bodyColor: _orange, accentColor: darken(_orange, 20),
      bootColor: rgba(160, 110, 30));
  // Sash across chest
  drawThickLine(im, 24, 26, 40, 38, 2, darken(_orange, 25));
  // Bandaged hands (override skin hands)
  fillShaded16Circle(im, _handLx, _handY, _handR, _bandageBeige);
  fillShaded16Circle(im, _handRx, _handY, _handR, _bandageBeige);
  // Bandage wrap lines
  setPixel(im, _handLx - 1, _handY, darken(_bandageBeige, 15));
  setPixel(im, _handLx + 1, _handY + 1, darken(_bandageBeige, 15));
  setPixel(im, _handRx - 1, _handY, darken(_bandageBeige, 15));
  setPixel(im, _handRx + 1, _handY + 1, darken(_bandageBeige, 15));
  return im;
}

img.Image _drawBarbarian() {
  final im = _newSprite();
  _drawAxe(im, 50, 38, silver);
  _drawBody(im, bodyColor: _brown, accentColor: rgba(180, 140, 80),
      bootColor: rgba(100, 70, 40));
  // Fur trim at neck
  fillShaded16Ellipse(im, 32, 23, 8, 2, rgba(180, 160, 120));
  _drawHornedHelmet(im, rgba(100, 100, 100));
  return im;
}

img.Image _drawSorcerer() {
  final im = _newSprite();
  // Fire orb in right hand
  _drawOrb(im, 48, 36, fireOrange, rgba(255, 100, 20, 80));
  fillShaded16Circle(im, 47, 33, 2, rgba(255, 220, 50));
  _drawBody(im, bodyColor: _crimson, accentColor: rgba(220, 80, 40));
  // Fiery trim
  _drawTrim(im, 44, rgba(255, 160, 40));
  return im;
}

img.Image _drawNecromancer() {
  final im = _newSprite();
  // Staff with skull top
  drawShadedLine(im, 50, 10, 50, 54, 3, rgba(60, 60, 70));
  // Skull
  fillShaded16Circle(im, 50, 7, 4, _skullWhite);
  fillRect(im, 48, 6, 49, 7, rgba(20, 20, 20)); // left eye socket
  fillRect(im, 51, 6, 52, 7, rgba(20, 20, 20)); // right eye socket
  setPixel(im, 50, 9, rgba(20, 20, 20)); // nose
  addHighlight(im, 48, 4, 1, 120);

  _drawBody(im, bodyColor: _necroBlack, accentColor: greenGlow);
  _drawHood(im, _necroBlack);
  // Green glow around hands
  fillCircle(im, _handRx, _handY, 4, rgba(80, 230, 80, 60));
  fillCircle(im, _handLx, _handY, 4, rgba(80, 230, 80, 60));
  return im;
}

img.Image _drawArtificer() {
  final im = _newSprite();
  _drawWrench(im, 50, 38);
  _drawBody(im, bodyColor: _copper, accentColor: rgba(180, 160, 100));
  _drawGearOnBody(im);
  _drawGoggles(im);
  return im;
}

img.Image _drawTemplar() {
  final im = _newSprite();
  _drawMace(im, 50, 38, silver);
  _drawShield(im, 14, 34, _templarWhite, darken(_templarWhite, 15));
  // Red cross on shield
  fillRect(im, 13, 30, 15, 38, redAccent);
  fillRect(im, 11, 33, 17, 35, redAccent);

  _drawBody(im, bodyColor: _templarWhite, accentColor: redAccent,
      bootColor: rgba(160, 160, 170));
  // Red cross on body
  fillRect(im, 31, 28, 33, 40, redAccent);
  fillRect(im, 27, 32, 37, 34, redAccent);
  _drawHelmet(im, rgba(200, 200, 210));
  return im;
}

// ── Main ──────────────────────────────────────────────────────────────

void main() {
  final classes = <String, img.Image Function()>{
    'fighter': _drawFighter,
    'rogue': _drawRogue,
    'cleric': _drawCleric,
    'wizard': _drawWizard,
    'paladin': _drawPaladin,
    'ranger': _drawRanger,
    'warlock': _drawWarlock,
    'summoner': _drawSummoner,
    'spellsword': _drawSpellsword,
    'druid': _drawDruid,
    'monk': _drawMonk,
    'barbarian': _drawBarbarian,
    'sorcerer': _drawSorcerer,
    'necromancer': _drawNecromancer,
    'artificer': _drawArtificer,
    'templar': _drawTemplar,
  };

  final dir = 'assets/sprites';
  Directory(dir).createSync(recursive: true);

  for (final entry in classes.entries) {
    stdout.write('Generating ${entry.key}... ');
    final sprite = entry.value();
    saveSprite(sprite, '$dir/${entry.key}');
    stdout.writeln('done');
  }

  print('\nAll 16 character sprites generated (64x64 + 240x240).');
}
