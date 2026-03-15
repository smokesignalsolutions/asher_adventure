import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/providers/player_profile_provider.dart';

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
  });
}
