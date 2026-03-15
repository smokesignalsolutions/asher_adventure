import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/providers/player_profile_provider.dart';
import 'package:asher_adventure/models/enums.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlayerProfileNotifier', () {
    test('initialize creates default profile when none exists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();

      final profile = container.read(playerProfileProvider);
      expect(profile, isNotNull);
      expect(profile!.legacyPoints, 0);
      expect(profile.unlockedClasses.length, 4);
    });

    test('addLegacyPoints increases balance and total', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(50);

      final profile = container.read(playerProfileProvider);
      expect(profile!.legacyPoints, 50);
      expect(profile.totalLegacyPointsEarned, 50);
    });

    test('recordRunEnd updates stats', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(
        mapsCompleted: 4,
        isVictory: false,
      );

      final profile = container.read(playerProfileProvider);
      expect(profile!.totalRuns, 1);
      expect(profile.totalVictories, 0);
      expect(profile.furthestMap, 4);
    });

    test('recordRunEnd tracks victories', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(
        mapsCompleted: 8,
        isVictory: true,
      );

      final profile = container.read(playerProfileProvider);
      expect(profile!.totalRuns, 1);
      expect(profile.totalVictories, 1);
      expect(profile.furthestMap, 8);
    });

    test('furthestMap only updates if new map is further', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.recordRunEnd(mapsCompleted: 5, isVictory: false);
      await notifier.recordRunEnd(mapsCompleted: 3, isVictory: false);

      final profile = container.read(playerProfileProvider);
      expect(profile!.furthestMap, 5);
    });

    test('purchaseClassUnlock deducts LP and adds class', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(100);

      final success = await notifier.purchaseClassUnlock(CharacterClass.paladin, 50);
      final profile = container.read(playerProfileProvider);

      expect(success, true);
      expect(profile!.legacyPoints, 50);
      expect(profile.unlockedClasses, contains(CharacterClass.paladin));
    });

    test('purchaseClassUnlock fails if insufficient LP', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();

      final success = await notifier.purchaseClassUnlock(CharacterClass.paladin, 50);
      expect(success, false);
    });

    test('purchasePassiveBonus increments rank', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(100);

      await notifier.purchasePassiveBonus('hp', 25, 10);
      await notifier.purchasePassiveBonus('hp', 25, 10);
      final profile = container.read(playerProfileProvider);

      expect(profile!.passiveBonuses['hp'], 2);
      expect(profile.legacyPoints, 50);
    });

    test('purchasePassiveBonus fails at max rank', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(500);

      for (int i = 0; i < 10; i++) {
        await notifier.purchasePassiveBonus('hp', 25, 10);
      }
      final success = await notifier.purchasePassiveBonus('hp', 25, 10);
      expect(success, false);
    });

    test('purchasePerk unlocks perk', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(playerProfileProvider.notifier);
      await notifier.initialize();
      await notifier.addLegacyPoints(100);

      final success = await notifier.purchasePerk('scavenger', 25);
      final profile = container.read(playerProfileProvider);

      expect(success, true);
      expect(profile!.unlockedPerks, contains('scavenger'));
      expect(profile.legacyPoints, 75);
    });
  });
}
