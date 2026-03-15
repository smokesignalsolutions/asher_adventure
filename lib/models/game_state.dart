import 'character.dart';
import 'enums.dart';
import 'game_map.dart';

class GameState {
  final List<Character> party;
  int gold;
  int healthPotions;
  int currentMapNumber;
  GameMap currentMap;
  DifficultyLevel difficulty;
  int totalEnemiesDefeated;
  int totalGoldEarned;
  double armyMoveAccumulator; // tracks partial army moves
  int mapsCompletedThisRun;
  int bossesKilledThisRun;
  Set<String> uniqueEnemyTypesKilledThisRun;

  GameState({
    required this.party,
    this.gold = 0,
    this.healthPotions = 0,
    this.currentMapNumber = 1,
    required this.currentMap,
    this.difficulty = DifficultyLevel.normal,
    this.totalEnemiesDefeated = 0,
    this.totalGoldEarned = 0,
    this.armyMoveAccumulator = 0.0,
    this.mapsCompletedThisRun = 0,
    this.bossesKilledThisRun = 0,
    Set<String>? uniqueEnemyTypesKilledThisRun,
  }) : uniqueEnemyTypesKilledThisRun = uniqueEnemyTypesKilledThisRun ?? {};

  Map<String, dynamic> toJson() => {
    'party': party.map((c) => c.toJson()).toList(),
    'gold': gold,
    'healthPotions': healthPotions,
    'currentMapNumber': currentMapNumber,
    'currentMap': currentMap.toJson(),
    'difficulty': difficulty.index,
    'totalEnemiesDefeated': totalEnemiesDefeated,
    'totalGoldEarned': totalGoldEarned,
    'armyMoveAccumulator': armyMoveAccumulator,
    'mapsCompletedThisRun': mapsCompletedThisRun,
    'bossesKilledThisRun': bossesKilledThisRun,
    'uniqueEnemyTypesKilledThisRun': uniqueEnemyTypesKilledThisRun.toList(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    party: (json['party'] as List)
        .map((c) => Character.fromJson(c))
        .toList(),
    gold: json['gold'],
    healthPotions: json['healthPotions'] ?? 0,
    currentMapNumber: json['currentMapNumber'],
    currentMap: GameMap.fromJson(json['currentMap']),
    difficulty: DifficultyLevel.values[json['difficulty']],
    totalEnemiesDefeated: json['totalEnemiesDefeated'] ?? 0,
    totalGoldEarned: json['totalGoldEarned'] ?? 0,
    armyMoveAccumulator: (json['armyMoveAccumulator'] as num?)?.toDouble() ?? 0.0,
    mapsCompletedThisRun: json['mapsCompletedThisRun'] ?? 0,
    bossesKilledThisRun: json['bossesKilledThisRun'] ?? 0,
    uniqueEnemyTypesKilledThisRun: json['uniqueEnemyTypesKilledThisRun'] != null
        ? Set<String>.from(json['uniqueEnemyTypesKilledThisRun'])
        : null,
  );
}
