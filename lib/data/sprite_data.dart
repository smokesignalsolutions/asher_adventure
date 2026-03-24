import '../models/enums.dart';

/// Returns 'low', 'mid', or 'high' based on story chapter progress.
String artTierForProgress(int progress) {
  if (progress >= 8) return 'high';
  if (progress >= 4) return 'mid';
  return 'low';
}

String classSpritePath(CharacterClass cls, [int storyProgress = 0]) {
  final tier = artTierForProgress(storyProgress);
  return 'assets/new_art/${cls.name}_${tier}_128x128.png';
}

/// Maps enemy types to asset filenames where they differ.
const _enemyTypeToAsset = {
  'orc': 'orc_grunt',
  'spider': 'giant_spider',
  'archdemon': 'arch_demon',
};

String enemySpritePath(String enemyType) {
  if (enemyType == 'boss') {
    return 'assets/new_art/goblin_king_256x256.png'; // fallback
  }
  final assetName = _enemyTypeToAsset[enemyType] ?? enemyType;
  return 'assets/new_art/${assetName}_low_128x128.png';
}

/// Maps enemy display names to sprite paths.
/// For bosses, uses 256x256 assets (no boss_ prefix in new_art).
/// For regular enemies, applies type-to-asset mapping then uses _low variant.
String enemySpritePathByName(String enemyName) {
  final normalized = enemyName
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll("'", '');

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
      return 'assets/new_art/${boss}_256x256.png';
    }
  }

  final assetName = _enemyTypeToAsset[normalized] ?? normalized;
  return 'assets/new_art/${assetName}_low_128x128.png';
}
