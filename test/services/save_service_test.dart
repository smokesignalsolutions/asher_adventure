import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asher_adventure/services/save_service.dart';
import 'package:asher_adventure/models/player_profile.dart';

void main() {
  group('SaveService - PlayerProfile', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveProfile and loadProfile round-trip', () async {
      final profile = PlayerProfile(
        legacyPoints: 100,
        totalRuns: 3,
        furthestMap: 5,
      );

      await SaveService.saveProfile(profile);
      final loaded = await SaveService.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.legacyPoints, 100);
      expect(loaded.totalRuns, 3);
      expect(loaded.furthestMap, 5);
    });

    test('loadProfile returns null when no profile saved', () async {
      final loaded = await SaveService.loadProfile();
      expect(loaded, isNull);
    });

    test('save and load run uses single key (no slots)', () async {
      await SaveService.autoSaveRun(
        _makeMockGameStateJson(),
      );
      final json = await SaveService.loadRunSaveJson();
      expect(json, isNotNull);

      await SaveService.deleteRunSave();
      final deleted = await SaveService.loadRunSaveJson();
      expect(deleted, isNull);
    });
  });
}

Map<String, dynamic> _makeMockGameStateJson() => {
  'party': [],
  'gold': 0,
  'healthPotions': 0,
  'currentMapNumber': 1,
  'currentMap': {
    'mapNumber': 1,
    'nodes': [],
    'armyColumn': -2.0,
    'currentNodeId': '',
  },
  'difficulty': 1,
};
