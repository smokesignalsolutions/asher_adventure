import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/services/legacy_point_calculator.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  group('LegacyPointCalculator', () {
    test('calculates base points from maps completed', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 0,
        uniqueEnemyTypesKilled: 0,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      expect(result.totalPoints, 30);
      expect(result.basePoints, 30);
    });

    test('adds boss kill bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 0,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      expect(result.bossBonus, 10);
      expect(result.totalPoints, 40);
    });

    test('adds unique enemy type bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 0,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      expect(result.enemyTypeBonus, 16);
      expect(result.totalPoints, 46);
    });

    test('adds victory bonus', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 8,
        bossesKilled: 8,
        uniqueEnemyTypesKilled: 20,
        isVictory: true,
        difficulty: DifficultyLevel.normal,
      );
      expect(result.victoryBonus, 25);
      expect(result.totalPoints, 185);
    });

    test('applies easy difficulty multiplier (0.5x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.easy,
      );
      expect(result.difficultyMultiplier, 0.5);
      expect(result.totalPoints, 33);
    });

    test('applies hard difficulty multiplier (1.5x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.hard,
      );
      expect(result.difficultyMultiplier, 1.5);
      expect(result.totalPoints, 99);
    });

    test('applies nightmare difficulty multiplier (2.0x)', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 4,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.nightmare,
      );
      expect(result.difficultyMultiplier, 2.0);
      expect(result.totalPoints, 132);
    });

    test('spec example: Normal, die on map 4, 2 bosses, 8 types', () {
      final result = LegacyPointCalculator.calculate(
        mapsCompleted: 3,
        bossesKilled: 2,
        uniqueEnemyTypesKilled: 8,
        isVictory: false,
        difficulty: DifficultyLevel.normal,
      );
      expect(result.totalPoints, 56);
    });
  });
}
