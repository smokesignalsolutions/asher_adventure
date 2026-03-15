import '../models/enums.dart';

class LegacyPointResult {
  final int basePoints;
  final int bossBonus;
  final int enemyTypeBonus;
  final int victoryBonus;
  final double difficultyMultiplier;
  final int totalPoints;

  const LegacyPointResult({
    required this.basePoints,
    required this.bossBonus,
    required this.enemyTypeBonus,
    required this.victoryBonus,
    required this.difficultyMultiplier,
    required this.totalPoints,
  });
}

class LegacyPointCalculator {
  static const int _pointsPerMap = 10;
  static const int _pointsPerBoss = 5;
  static const int _pointsPerEnemyType = 2;
  static const int _victoryBonus = 25;

  static double _multiplierForDifficulty(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 0.5;
      case DifficultyLevel.normal:
        return 1.0;
      case DifficultyLevel.hard:
        return 1.5;
      case DifficultyLevel.nightmare:
        return 2.0;
    }
  }

  static LegacyPointResult calculate({
    required int mapsCompleted,
    required int bossesKilled,
    required int uniqueEnemyTypesKilled,
    required bool isVictory,
    required DifficultyLevel difficulty,
  }) {
    final basePoints = mapsCompleted * _pointsPerMap;
    final bossBonus = bossesKilled * _pointsPerBoss;
    final enemyTypeBonus = uniqueEnemyTypesKilled * _pointsPerEnemyType;
    final victoryBonus = isVictory ? _victoryBonus : 0;
    final multiplier = _multiplierForDifficulty(difficulty);

    final rawTotal = basePoints + bossBonus + enemyTypeBonus + victoryBonus;
    final totalPoints = (rawTotal * multiplier).round();

    return LegacyPointResult(
      basePoints: basePoints,
      bossBonus: bossBonus,
      enemyTypeBonus: enemyTypeBonus,
      victoryBonus: victoryBonus,
      difficultyMultiplier: multiplier,
      totalPoints: totalPoints,
    );
  }
}
