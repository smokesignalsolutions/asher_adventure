import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/models/player_profile.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  group('PlayerProfile', () {
    test('creates with default values', () {
      final profile = PlayerProfile();
      expect(profile.legacyPoints, 0);
      expect(profile.totalLegacyPointsEarned, 0);
      expect(profile.totalRuns, 0);
      expect(profile.totalVictories, 0);
      expect(profile.furthestMap, 0);
      expect(profile.unlockedClasses, containsAll([
        CharacterClass.fighter,
        CharacterClass.rogue,
        CharacterClass.cleric,
        CharacterClass.wizard,
      ]));
      expect(profile.unlockedClasses.length, 4);
    });

    test('serializes to JSON and back', () {
      final profile = PlayerProfile(
        legacyPoints: 150,
        totalLegacyPointsEarned: 300,
        totalRuns: 5,
        totalVictories: 1,
        furthestMap: 6,
        unlockedClasses: [
          CharacterClass.fighter,
          CharacterClass.rogue,
          CharacterClass.cleric,
          CharacterClass.wizard,
          CharacterClass.paladin,
        ],
      );

      final json = profile.toJson();
      final restored = PlayerProfile.fromJson(json);

      expect(restored.legacyPoints, 150);
      expect(restored.totalLegacyPointsEarned, 300);
      expect(restored.totalRuns, 5);
      expect(restored.totalVictories, 1);
      expect(restored.furthestMap, 6);
      expect(restored.unlockedClasses.length, 5);
      expect(restored.unlockedClasses, contains(CharacterClass.paladin));
    });

    test('fromJson handles missing keys with defaults', () {
      final json = <String, dynamic>{};
      final profile = PlayerProfile.fromJson(json);
      expect(profile.legacyPoints, 0);
      expect(profile.unlockedClasses.length, 4);
    });

    test('passiveBonuses and unlockedPerks serialize', () {
      final profile = PlayerProfile(
        passiveBonuses: {'hp': 3, 'attack': 1},
        unlockedPerks: ['scavenger', 'veteran'],
      );
      final json = profile.toJson();
      final restored = PlayerProfile.fromJson(json);
      expect(restored.passiveBonuses['hp'], 3);
      expect(restored.passiveBonuses['attack'], 1);
      expect(restored.unlockedPerks, contains('scavenger'));
      expect(restored.unlockedPerks, contains('veteran'));
    });
  });
}
