import '../models/enums.dart';

String classSpritePath(CharacterClass cls) {
  return 'assets/sprites/${cls.name}.png';
}

String enemySpritePath(String enemyType) {
  // Boss types map to boss_ prefixed sprites
  switch (enemyType) {
    case 'boss':
      return 'assets/sprites/enemies/boss_goblin_king.png'; // fallback
    default:
      return 'assets/sprites/enemies/$enemyType.png';
  }
}

// Map enemy names to sprite file names for bosses
String enemySpritePathByName(String enemyName) {
  final normalized = enemyName
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll("'", '');

  // Check if it's a known boss
  const bosses = [
    'goblin_king',
    'bone_lord',
    'shadow_witch',
    'mountain_giant',
    'lich_king',
    'demon_prince',
    'dragon_emperor',
    'the_dark_one',
  ];

  for (final boss in bosses) {
    if (normalized == boss) {
      return 'assets/sprites/enemies/boss_$boss.png';
    }
  }

  // Regular enemy - use type
  return 'assets/sprites/enemies/$normalized.png';
}
