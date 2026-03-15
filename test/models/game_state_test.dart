import 'package:flutter_test/flutter_test.dart';
import 'package:asher_adventure/models/game_state.dart';
import 'package:asher_adventure/services/map_service.dart';

void main() {
  group('GameState run tracking', () {
    test('new GameState has zeroed run tracking fields', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
      );
      expect(state.mapsCompletedThisRun, 0);
      expect(state.bossesKilledThisRun, 0);
      expect(state.uniqueEnemyTypesKilledThisRun, isEmpty);
    });

    test('run tracking fields serialize and deserialize', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
        mapsCompletedThisRun: 3,
        bossesKilledThisRun: 2,
        uniqueEnemyTypesKilledThisRun: {'goblin_grunt', 'goblin_shaman'},
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.mapsCompletedThisRun, 3);
      expect(restored.bossesKilledThisRun, 2);
      expect(restored.uniqueEnemyTypesKilledThisRun, hasLength(2));
      expect(restored.uniqueEnemyTypesKilledThisRun, contains('goblin_grunt'));
    });

    test('default gold is 0', () {
      final state = GameState(
        party: [],
        currentMap: MapService.generateMap(1),
      );
      expect(state.gold, 0);
    });
  });
}
